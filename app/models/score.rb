class Score < ApplicationRecord
  has_one :result
  with_options presence: true do
    validates :france
    validates :germany
    validates :france_pk
    validates :germany_pk
  end
  
  with_options numericality: { only_integer: true } do
    validates :france
    validates :germany
    validates :france_pk
    validates :germany_pk
  end

  def self.total_wins
    return 'ð«ð·åã¡æ°ð©ðª' + "\n" + Score.where("france + france_pk > germany + germany_pk").count.to_s + 'å' + " - " + Score.where("france + france_pk < germany + germany_pk").count.to_s + 'å' + "\n" + "\n"
  end

  def self.scoring_rate
    return 'ð«ð·åŸç¹çð©ðª' + "\n" + "#{Score.average(:france).round(1).to_s}ç¹" + ' - ' + "#{Score.average(:germany).round(1).to_s}ç¹" + "\n" + "\n"
  end

  def self.total_scores
    total_france_score = Score.sum(:france)
    total_germany = Score.sum(:germany)
    return 'ð«ð·ç·åŸç¹ð©ðª' + "\n" + "#{total_france_score.to_s}ç¹" + ' - ' + "#{total_germany.to_s}ç¹" + "\n" + "\n"
  end

  def self.total_matches
    return 'ð«ð·ç·è©Šåæ°ð©ðª' + "\n" +  Score.count.to_s + 'è©Šå' + "\n" + "\n"
  end

  def self.is_next_match?
    next_matche = Score.count + 1
    (next_matche % 10 == 0) ? "æ¬¡ã¯èšå¿µãã¹ã#{next_matche}è©Šåç®ãã§ãïŒïŒ" : "æ¬¡ã¯ã©ã£ã¡ãåã€ããªïŒ"
  end

  def self.match_result(scores, text)
    text << (scores.length == 1 ? 'ð«ð·åŸç¹ð©ðª' : 'ð«ð·çŽè¿ïŒè©Šåã®çµæð©ðª')
    text << "\n"
    scores.each do |score|
      text << score[:france].to_s + ' ' + '-' + ' ' + score[:germany].to_s
      text << 'ïŒ' + ' ' + score[:france_pk].to_s + ' ' + '-' + ' ' + score[:germany_pk].to_s + ' ' + 'ïŒ' unless (score[:france_pk] == 0 && score[:germany_pk] == 0)
      text << "\n"
    end
    text << "\n"
  end

  def self.save_from_message(scores)
    # pkæŠãããªããã°0ãä»£å¥ãã
    if scores.length == 2
      pk_flanse_score = 0
      germany_pk = 0
    end

    if scores.length == 4
      pk_flanse_score = scores[2]
      germany_pk = scores[3]
    end

    raise ArgumentError, "#{scores} is invalid length" unless scores.length == 2 || scores.length == 4

    winner = (scores[0] + pk_flanse_score > scores[1] + germany_pk) ? "FRANCE" : "GERMANY"
    loser = (winner == "FRANCE") ? "GERMANY" : "FRANCE"
    score = Score.new(france: scores[0], germany: scores[1], france_pk: pk_flanse_score, germany_pk: germany_pk)
    result = score.build_result(winner: Object.const_get("Country::#{winner}"), loser: Object.const_get("Country::#{loser}"))

    raise ArgumentError, "#{scores} is invalid values" if score.invalid? || (scores[0] + pk_flanse_score) == (scores[1] + germany_pk)

    score.save!
  end

  def self.results
    text = ''
    text << Score.total_matches
    scores = Score.all.order(id: 'DESC').limit(5)
    Score.match_result(scores, text)

    text << Score.total_wins
    text << Score.scoring_rate
    text << Score.total_scores
    text << Score.is_next_match?
  end
end
