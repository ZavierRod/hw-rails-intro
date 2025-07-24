class Movie < ApplicationRecord
  RATINGS = ['G','PG','PG-13','R']
  def self.all_ratings
    return RATINGS
  end

  def self.with_ratings(list_of_ratings)
    if list_of_ratings.nil? || list_of_ratings.empty?
      return Movie.all
    else
      filtered_list = list_of_ratings & Movie.all_ratings
      Movie.where(rating: filtered_list)
    end
  end
end
