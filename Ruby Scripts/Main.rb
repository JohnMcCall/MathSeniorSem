#!/usr/bin/env ruby

require "rubygems"
require "polynomial"
require "./Encoder"
require "./CoefficientArithmetic.rb"
require "./MyPolynomial.rb"


encoder = Encoder.new
ca = CoefficientArithmetic.new

@vc = encoder.getValidCharacters
replacements = ca.getReplacements

#encoder.isPrimitive(0b100)

#encoder.printLatexAddTable()

#puts encoder.add(['$', '0', '#', ',', 'P', '%'])
#puts encoder.add(['#', ',', '4', '\\', 'U'])
#puts encoder.add(['%', '4', '/', '\\', 'U', '1', '<', '5'])
#puts encoder.add(['\\', 'U', '<', 'D', '6'])
#puts encoder.add(['S', ')', 'D', '6', ';', 'O'])

def generateCoefs(string)
    toReturn = []
    
    string.split(//).each do |char|
        index = @vc.rindex(char)
        toReturn.push(index)
    end
    
    toReturn
end

#mCoefs = generateCoefs("THIS IS MAJOR TOM")
#gCoefs = generateCoefs("Z\\G/2N!")

#m = Polynomial.new(mCoefs)
#g = Polynomial.new(gCoefs)

#result = (Polynomial.new([0,0,0,0,0,0,1]) * m) % g
#result = m * g

#temp = result.coefs.dup
#temp = temp.map! {|x| x % 63}

#temp.each do |char|
#    puts @vc[char]
#end

#p m % g

###

#roots = ('A'..'Q').to_a

#l = Polynomial.new([1])

#roots.each do |char|
#    l = (Polynomial.new([-@vc.rindex(char), 1]) * l)
#end

#l = encoder.modX(l, 63)

#roots.each do |char|
#    result = (l / Polynomial.new([-@vc.rindex(char), 1])).substitute(@vc.rindex(char))
#    puts @vc[result % 63]
#end


p1 = MyPolynomial['!', '!', '$']
p2 = MyPolynomial['#', ' ', '!']

puts "P1: " + p1.to_s
puts "P2: " + p2.to_s
puts "P1 * P2: " + (p1 * p2).to_s


