# frozen_string_literal: true
# encoding: utf-8

class Product < ActiveRecord::Base
  has_many :orders
  validates_presence_of :name, :price

  def list_name
    "#{name} - #{price.round.to_i} #{currency}"
  end

  def price_in_cents
    price.round * 100
  end

  def self.active
    where(active: true)
  end

  def self.ordered
    order(:price)
  end
end
