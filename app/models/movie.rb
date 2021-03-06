class Movie < ApplicationRecord

  has_many :rentals

  validates :title, :inventory, :available_inventory, presence: true

  validates :inventory, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  validates :available_inventory, numericality: { only_integer: true, greater_than_or_equal_to: 0}

  validate :available_inventory_cannot_exceed_inventory

  def available_inventory_cannot_exceed_inventory
    if inventory
      if inventory < available_inventory
        errors.add(:available_inventory, "Cannot exceed inventory")
      end
    end
  end

  def self.decrement(movie)
    if movie.available_inventory > 0
      movie.available_inventory -= 1
      movie.save
    end
  end

  def self.increment(movie)
    if movie.available_inventory < movie.inventory
      movie.available_inventory += 1
      movie.save
    end
  end

  def self.rentable_movie?(id)
      movie = Movie.find_by(id: id)
      if movie.available_inventory < 1
        movie = false
      end
    return movie
  end

  def self.returnable_movie?(id)
    movie = false

    if Movie.find_by(id: id)
      movie = Movie.find_by(id: id)
      if movie.available_inventory == movie.inventory
        movie = false
      end
    end
    return movie
  end

end
