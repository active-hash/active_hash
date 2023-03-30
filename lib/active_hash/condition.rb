class ActiveHash::Relation::Condition
  attr_reader :constraints, :inverted

  def initialize(constraints)
    @constraints = constraints
    @inverted = false
  end

  def invert!
    @inverted = !inverted

    self
  end

  def matches?(record)
    match = begin
      return true unless constraints

      expectation_method = inverted ? :any? : :all?

      constraints.send(expectation_method) do |attribute, expected|
        value = record.public_send(attribute)

        matches_value?(value, expected)
      end
    end

    inverted ? !match : match
  end

  private

  def matches_value?(value, comparison)
    return comparison.any? { |v| matches_value?(value, v) } if comparison.is_a?(Array)
    return comparison.cover?(value) if comparison.is_a?(Range)
    return comparison.match?(value) if comparison.is_a?(Regexp)

    normalize(value) == normalize(comparison)
  end

  def normalize(value)
    value.respond_to?(:to_s) ? value.to_s : value
  end
end