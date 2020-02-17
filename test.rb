$:.unshift 'lib'
require 'active_hash'

class Foo < ActiveHash::Base
  field :name
  field :age
  field :stuff, :private => true

  self.data = [
    {:name => 'Dan', :age => 50, :stuff => 'secret'},
    {:name => 'Joe', :age => 35, :stuff => 'secret'}
  ]
end

#p Foo.all
f = Foo.first
p f.stuff
