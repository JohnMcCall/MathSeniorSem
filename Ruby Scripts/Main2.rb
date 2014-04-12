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

puts ca.add(['\\', 'L', 'Q', 'M', 'N', '<', 'W', 'V', '?', '0', 'S', 'O', 'N', '(', '7', '$', '!', 'W', 'A', '2', '-', ']', 'L'])

=begin
map = Hash.new()
element = 'A'
acc = '!'
poly = MyPolynomial['!']
(1..5).each do |i|
  acc = ca.multiply([acc, element])
  poly = poly + MyPolynomial[i => acc]
end 

map[element] = (poly * MyPolynomial['!', 'A'])

puts map["A"].to_s
=end

=begin
rNeg1 = MyPolynomial[6=>'!']
r0 = MyPolynomial[']', ']', ' ', '7', ' ', '1']
r1 = MyPolynomial[' ', '+', '+', ' ', 'S']
r2 = MyPolynomial[']', ']', 'X', 'O']
puts r1.to_s
puts r2.to_s
q, r = r1.divmod(r2)
puts q
puts r
puts ((q * r2) + r).to_s

puts (MyPolynomial[' ', 'V'] + (MyPolynomial['Z', 'J'] * MyPolynomial['!', '^'])).to_s



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
=end

# Now we can create our message polynomial.
message = "THIS IS MAJOR TOM"
messagePoly = MyPolynomial.new(message.split(//))
puts "f(x) = " + messagePoly.to_s
puts

=begin
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
=end

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
a = ('A'..'Q').to_a
puts "a = " + a.to_s
puts
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

# Lets say that the message we recieved is "THIS IS MAYOR TED".
# we calculate the Syndrome Polynomial for the received message vector, p.
p = "THIS IS MAYOR TED".split(//)
puts "p = " + p.to_s
puts 

## First generate the ui * pi and add them to an array
products = []
(0...u.length).each do |i|
    products.push(MyPolynomial[ca.multiply([u[i], p[i]])])
end

denom = MyPolynomial['!']
a.each do |elt|
    denom = denom * MyPolynomial['!', elt]
end

#  -- Again this took a long time so I ran it once and hardcoded the result into the program
sp = MyPolynomial[' ']
(0...u.length).each do |i|
    mult = denom / MyPolynomial['!', a[i]]
    # mod by z^6 by taking the first 6 coefs and creating a new poly from them
    product = products[i] * mult    
    mod6 = MyPolynomial.new(product.coefs.take(6))
    sp = sp + mod6
end


#sp = MyPolynomial[']', ']', ' ', '7', ' ', '1']
puts sp.to_s
puts


