class Solution
  class Create
    include Mandate
    initialize_with :user, :exercise

    def call
      guard!

      begin
        solution_class.create!(user: user, exercise: exercise).tap do |solution|
          record_activity!(solution)
        end
      rescue ActiveRecord::RecordNotUnique
        solution_class.find_by!(
          user: user,
          exercise: exercise
        )
      end
    end

    private
    def guard!
      raise UserTrackNotFoundError if user_track.external?
      raise ExerciseLockedError unless user_track.exercise_unlocked?(exercise)
    end

    def record_activity!(solution)
      User::Activity::Create.(
        :started_exercise,
        user,
        track: exercise.track,
        solution: solution
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end

    def solution_class
      case exercise
      when ConceptExercise
        ConceptSolution
      when PracticeExercise
        PracticeSolution
      else
        # Guard against some further third type
        raise RuntimeError
      end
    end

    memoize
    def user_track
      UserTrack.for(user, exercise.track)
    end
  end
end
