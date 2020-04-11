function rentv
  filebot -r -rename $DIR_INPUT_TV --output $DIR_OUTPUT_TV --db TheTvDB -non-strict --format "{n}/Season {s.pad(2)}/{n} {s00e00} - {t}"
end

function subtv
  filebot -script fn:suball $DIR_OUTPUT_TV -non-strict --def maxAgeDays=7
end

function tv
  rentv && subtv
end

function renmov
  filebot -r -rename $DIR_INPUT_MOVIES --output $DIR_OUTPUT_MOVIES --db TheMovieDB -non-strict --format "{y} - {n}/{n} ({y})"
end

function submov
  filebot -script fn:suball $DIR_OUTPUT_MOVIES -non-strict --def maxAgeDays=7
end

function mov
  renmov && submov
end

function subs
  filebot -get-subtitles $argv
end
