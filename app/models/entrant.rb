class Entrant < ActiveRecord::Base

  validates :first_name, :surname, :year, :email, :variable_symbol, :presence => true

  validates :email, :format => {:with => /\A^[_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,4})$\z/}
  validates :variable_symbol, uniqueness: true
  validates :year, numericality: {only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: 2004}

  before_validation :generate_vs, on: :create
  after_create :send_email

  def to_mail
    "#{self.to_s} <#{self.email}>"
  end

  def to_s
    "#{self.first_name} #{self.surname}"
  end

  private

  def generate_vs
    return unless self.variable_symbol.blank?
    begin
      vs = Time.now.strftime("%m%d%H") + rand(10000).to_s.rjust(4, '0')
    end while Entrant.exists?(variable_symbol: vs)
    self.variable_symbol = vs
  end

  def send_email
    return if self.variable_symbol[0..3].eql?('0000')
    EntrantMailer.registration(self).deliver
  end

end
