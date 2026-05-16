class ActiveHash::Relation::Conditions
  attr_reader :conditions

  delegate :<<, :map, to: :conditions

  def initialize(conditions = [])
    @conditions = conditions
  end

  def initialize_copy(orig)
    super
    @conditions = @conditions.dup
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