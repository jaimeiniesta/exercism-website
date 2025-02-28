require 'test_helper'

class Submission::TestRun::ProcessTest < ActiveSupport::TestCase
  test "should not do anything if the test run is not pending" do
    submission = create :submission
    job = create_test_runner_job!(submission, execution_status: 200, results: {})

    submission.tests_cancelled!
    Submission::TestRun::Process.(job)

    assert submission.reload.tests_cancelled?
    assert_equal :cancelled, submission.test_run.status
  end

  test "creates test_run record" do
    submission = create :submission
    ops_status = 201
    status = "foobar"
    message = "some barfoo message"
    version = 5
    tests = [{ 'foo' => 'bar' }]
    results = { 'version' => version, 'status' => status, 'message' => message, 'tests' => tests }
    job = create_test_runner_job!(submission, execution_status: ops_status, results: results)

    Submission::TestRun::Process.(job)

    tr = submission.reload.test_run

    assert_equal ops_status, tr.ops_status
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal version, tr.version
    assert_equal results, tr.send(:raw_results)
  end

  test "handle ops error" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 500, results: results)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_exceptioned?
  end

  test "handle tests pass" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results: results)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_passed?
  end

  test "handle tests fail" do
    submission = create :submission
    results = { 'status' => 'fail', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results: results)

    # Cancel representation and analysis
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :analyzer)
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :representer)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_failed?
  end

  test "handle tests error" do
    submission = create :submission
    results = { 'status' => 'error', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results: results)

    # Cancel representation and analysis
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :analyzer)
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :representer)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_errored?
  end

  test "handle bad status" do
    submission = create :submission
    results = { 'status' => 'oops', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results: results)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_exceptioned?
  end

  test "broadcast without iteration" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results: results)

    SubmissionChannel.expects(:broadcast!).with(submission)
    Submission::TestRunsChannel.expects(:broadcast!).with(kind_of(Submission::TestRun))

    Submission::TestRun::Process.(job)

    assert submission.test_run
  end

  test "broadcast with iteration" do
    submission = create :submission
    iteration = create :iteration, submission: submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results: results)

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)
    Submission::TestRunsChannel.expects(:broadcast!).with(kind_of(Submission::TestRun))

    Submission::TestRun::Process.(job)
  end
end
