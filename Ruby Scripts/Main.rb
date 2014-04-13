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

puts MyPolynomial['?', ']', 'E'].substitute('3').to_s
puts MyPolynomial['Z', ' ', 'C'].substitute('3').to_s

def euclid(r0, r1)
    s = [MyPolynomial['!'], MyPolynomial[' ']]
    t = [MyPolynomial[' '],MyPolynomial['!']]
    r = [r0, r1]
    q = ['', '']

    step = 2
    while (r[step - 1].degree() >= 3) do
        qNew, rNew = r[step-2].divmod(r[step-1])
        r.push(rNew)
        q.push(qNew)
        
        sNew = (s[step-2] + (q[step] * s[step-1]))
        s.push(sNew)
        
        tNew = (t[step-2] + (q[step] * t[step-1]))
        t.push(tNew)
        
        step = step + 1
    end
    
    puts s.to_s
    puts t.to_s
    puts r.to_s
    puts q.to_s
    puts

end


sigma = MyPolynomial['!', 'Z', 'L', 'C']
vc.each do |elt|
    if (sigma.substitute(elt) == ' ')
        puts elt
    end
end



# Now we can create our message polynomial.
message = "THIS IS MAJOR TOM"
messagePoly = MyPolynomial.new(message.split(//))
puts "f(x) = " + messagePoly.to_s
puts

# Now that we have f(x), we can use it to calculate a codeword, c.
# For this example C = GRS(a,v), where v = ('!','!'...'!').
a = ('A'..'W').to_a
puts "a = " + a.to_s
puts

c = []
a.each do |elt|
    c.push(messagePoly.substitute(elt))
end
puts "c = " + c.to_s
puts

# We want to find a vector u for the dual code of C = GRS(a, u).
# Note: This calculation took a really long time. So I hard coded in the
# value for l and u so I don't have to sit through the calculation everytime.
l = MyPolynomial.new([".", "/", "S", "'", "9", "X", "<", "I", "X", "Y", "^", "5", "@", "!", "_", "J", ";", "(", ")", ".", "H", "P", "@", "!"])

#puts "Product: " + ca.multiply(a)

=begin
l = '!'
a.each do |elt|
    l = MyPolynomial[elt, '!'] * l
    puts l.to_s
end

puts l.divmod(MyPolynomial['W', '!']).to_s
=end

#puts "l(x) coefs: " + l.coefs.to_a.to_s
=begin
u = []
a.each do |elt|
    result = (l / MyPolynomial[elt, '!']).substitute(elt)
    u.push(ca.findInverse(result))
end
=end

u = ["2", "D", "V", "+", "9", "O", "]", "G", "*", "^", "3", "5", "X", ",", "A", "A", ">", "<", "C", "8", "G", "E", ":"]

puts "Assuming these are correct:"
puts "u = " + u.to_s
puts

# Lets say that the message we recieved is different from c in 3 places.
# c[6] was a "G", is now a "Z"
# c[10] was a "4" is now a "&"
# c[21] was a "<" is now a "R"
# we calculate the Syndrome Polynomial for the received message vector, p.
p = ["T", "(", "U", "8", "P", "K", "Z", "N", "W", "P", "&", "K", "'", "_", "N", "(", "M", "H", "K", "1", "\"", "R", "K"]
puts "p = " + p.to_s
puts

inverses = Hash.new()

a.each do |elt|
  acc = '!'
  poly = MyPolynomial['!']
  (1..5).each do |i|
    acc = ca.multiply([acc, elt])
    poly = poly + MyPolynomial[i => acc]
  end 

  inverses[elt] = poly
end

## First generate the ui * pi and add them to an array
products = []
(0...u.length).each do |i|
    products.push(MyPolynomial[ca.multiply([u[i], p[i]])])
end

sp = MyPolynomial[' ']
(0...a.length).each do |i|
  product = inverses[a[i]] * products[i]
  sp = sp + product
end

#sp = MyPolynomial['L', "[", '@', '5', '6', '\\']
puts "Sp = " + sp.to_s
puts

#Euclids Algorithm
euclid(MyPolynomial[6 => "!"], sp)

