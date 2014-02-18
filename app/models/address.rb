# encoding: utf-8

class Address < PRXModel

  belongs_to :addressable, :polymorphic => true

end
