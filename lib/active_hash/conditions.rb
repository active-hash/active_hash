class ActiveHash::Relation::Conditions
  attr_reader :conditions

  delegate_missing_to :conditions

  def initialize(conditions = [])
    @conditions = conditions
  end

  def matches?(record)
    conditions.all? do |condition|
      condition.matches?(record)
    end
  end

  def self.wrap(conditions)
    return conditions if conditions.is_a?(self)

    new(conditions)
  end
end