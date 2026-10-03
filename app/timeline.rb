# frozen_string_literal: true
# Pure Ruby: independently testable, wrap-safe, no timers or external services.
module LobbyTimeline
  def self.duration(scenes)
    scenes.inject(0.0) { |sum, scene| sum + scene[:duration] }
  end

  def self.at(seconds, scenes, fade)
    remaining = seconds % duration(scenes)
    index = 0
    while remaining >= scenes[index][:duration]
      remaining -= scenes[index][:duration]
      index += 1
    end
    length = scenes[index][:duration]
    mix = [[(remaining - (length - fade)) / fade, 0.0].max, 1.0].min
    # Smoothstep: motion has no sharp acceleration at either end of a dissolve.
    mix = mix * mix * (3.0 - 2.0 * mix)
    { index: index, elapsed: remaining, progress: remaining / length,
      next_index: (index + 1) % scenes.length, mix: mix }
  end
end
