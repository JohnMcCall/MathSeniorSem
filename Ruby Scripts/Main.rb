#!/usr/bin/env ruby

require "rubygems"
require "polynomial"
require "./Encoder"
require "./CoefficientArithmetic.rb"
require "./MyPolynomial.rb"


# Here we create instances of Encoder and CoefficientArithmetic.
# These will be used in computations to come.
encoder = Encoder.new
ca = CoefficientArithmetic.new

vc = encoder.getValidCharacters
replacements = ca.getReplacements


# The first step it to find a primitive element. 
# Using the isPrimitive method, we can test many different 
# elements quickly. Here, I found that $ is a primitive element.
puts "$ is a primitive element: " + ca.isPrimitive('$').to_s
puts


# Next we create a generater polynomial using the primitive element.
# For our example, we will have n - k = 17 - 11 = 6 roots.
roots = 6
generatorPoly = MyPolynomial["!"]
(1..roots).each do |n|
    generatorPoly = MyPolynomial[ca.exp('$', n), '!'] * generatorPoly
end
puts "g(x) = " + generatorPoly.to_s
puts


# Now we can create our message polynomial.
message = "THIS IS MAJOR TOM"
messagePoly = MyPolynomial.new(message.split(//))
puts "m(x) = " + messagePoly.to_s
puts


# The next thing we need to do is upshift the degree of our message polynomial.
# We do this buy multiplying the polynomial by x^(n-k) = x^6
upshiftedMessage = MyPolynomial[6 => '!'] * messagePoly
puts "x^6 * m(x) = " + upshiftedMessage.to_s
puts


# Now we need to find the parity bits. The equation for finding the
# partity bits, p(x), is: p(x) = (x^(n-k) * m(x)) mod g(x)
parityPoly = upshiftedMessage % generatorPoly
puts "p(x) = " + parityPoly.to_s
puts


# Then, we add the parity bits to the upshifted message to get our
# codeword polynomial, f(x).
codewordPoly = parityPoly + upshiftedMessage
puts "f(x) = " + codewordPoly.to_s
puts


# Now that we have f(x), we can use it to calculate a codeword, C.
# For this example C = GRS(a,v), where v = (1,1...1).
# We want to find a vector u for the dual code of C = GRS(a, u).
# Note: This calculation took a really long time. So I hard coded in the
# value for u so I don't have to sit through the calculation everytime.
a = ('A'..'Q')
=begin
l = '!'
a.each do |elt|
    l = MyPolynomial[elt, '!'] * l
end

u = []
a.each do |elt|
    result = (l / MyPolynomial[elt, '!']).substitute(elt)
    u.push(ca.findInverse(result))
end
=end

u = [":", "X", "D", "*", "I", "^", "*", "'", "N", "(", "B", "3", "?", "X", "\\", "J", "P"]

puts "u = " + u.to_s
puts




