require "test_helper"

class ContributorTeam::UpdateReviewersTeamPermissionsTest < ActiveSupport::TestCase
  test "adds reviewer team to team if no maintainers in team" do
    skip # TODO: enable this once we are confident that org member syncing works
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    team = create :contributor_team, github_name: 'csharp'

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp").
      to_return(status: 200, body: { id: 555 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(status: 200, body: { id: 777 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.github.com/teams/555/repos?per_page=100").
      to_return(status: 200, body: [{ full_name: "exercism/csharp" },
                                    { full_name: "exercism/ruby" }].to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://api.github.com/teams/777/repos/exercism/csharp").
      with(body: { permission: "push" }.to_json).
      to_return(status: 200, body: "", headers: {})

    stub_request(:put, "https://api.github.com/teams/777/repos/exercism/ruby").
      with(body: { permission: "push" }.to_json).
      to_return(status: 200, body: "", headers: {})

    ContributorTeam::UpdateReviewersTeamPermissions.(team)
  end

  test "adds reviewer team to team if one maintainer in team" do
    skip # TODO: enable this once we are confident that org member syncing works
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    team = create :contributor_team, github_name: 'csharp'
    create :contributor_team_membership, team: team

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp").
      to_return(status: 200, body: { id: 555 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(status: 200, body: { id: 777 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.github.com/teams/555/repos?per_page=100").
      to_return(status: 200, body: [{ full_name: "exercism/csharp" },
                                    { full_name: "exercism/ruby" }].to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://api.github.com/teams/777/repos/exercism/csharp").
      with(body: { permission: "push" }.to_json).
      to_return(status: 200, body: "", headers: {})

    stub_request(:put, "https://api.github.com/teams/777/repos/exercism/ruby").
      with(body: { permission: "push" }.to_json).
      to_return(status: 200, body: "", headers: {})

    ContributorTeam::UpdateReviewersTeamPermissions.(team)
  end

  test "removes reviewer team from team if two or more maintainers" do
    skip # TODO: enable this once we are confident that org member syncing works
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    team = create :contributor_team, github_name: 'csharp'
    create :contributor_team_membership, team: team
    create :contributor_team_membership, team: team

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp").
      to_return(status: 200, body: { id: 555 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/reviewers").
      to_return(status: 200, body: { id: 777 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.github.com/teams/555/repos?per_page=100").
      to_return(status: 200, body: [{ full_name: "exercism/csharp" },
                                    { full_name: "exercism/ruby" }].to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:delete, "https://api.github.com/teams/777/repos/exercism/csharp").
      to_return(status: 200, body: "", headers: {})

    stub_request(:delete, "https://api.github.com/teams/777/repos/exercism/ruby").
      to_return(status: 200, body: "", headers: {})

    ContributorTeam::UpdateReviewersTeamPermissions.(team)
  end

  test "does not do
    skip # TODO: enable this once we are confident that org member syncing works anything if team is reviewer team" do
    skip # TODO: enable this once we are confident that org member syncing works
    team = create :contributor_team, github_name: 'reviewers'

    ContributorTeam::UpdateReviewersTeamPermissions.(team)
  end
end
