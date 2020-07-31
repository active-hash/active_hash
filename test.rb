$:.unshift 'lib'
require 'active_hash'

class Foo < ActiveHash::Base
  field :name
  field :age
  field :stuff, :private => true

  # private

  # def stuff
  #   @stuff || "sekret"
  # end

  # def stuff= val
  #   @stuff = val
  # end

  self.data = [
    {:name => 'Dan', :age => 50, :stuff => 'secret'},
    {:name => 'Joe', :age => 35, :stuff => 'sekret'}
  ]
end

#p Foo.all
f = Foo.first
p f.name
p f.age
p f.stuff
