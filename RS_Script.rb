#!/usr/bin/env ruby

require "rubygems"
require "polynomial"

class Encoder

    def initialize()
        super()
        @validCharacters = [' ', '!', '"', '#', '$', '%', '&', '\'', 
                            '(', ')', '*', '+', ',', '-', '.', '/',
                            '0', '1', '2', '3', '4', '5', '6', '7',
                            '8', '9', ':', ';', '<', '=', '>', '?',
                            '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
                            'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
                            'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
                            'X', 'Y', 'Z', '[', '\\', ']', '^', '_']

        @replacements = [Polynomial.new(1, 1), Polynomial.new(0, 1, 1), 
                         Polynomial.new(0, 0, 1, 1), Polynomial.new(0, 0, 0, 1, 1), 
                         Polynomial.new(0, 0, 0, 0, 1, 1)]

        @polys = [Polynomial.new(0,0,0,0,0,0,1), Polynomial.new(0,0,0,0,0,0,0,1), 
                  Polynomial.new(0,0,0,0,0,0,0,0,1), Polynomial.new(0,0,0,0,0,0,0,0,0,1), 
                  Polynomial.new(0,0,0,0,0,0,0,0,0,0,1)]

    end

    def getValidCharacters()
        @validCharacters
    end

    def getReplacements()
        @replacements
    end

    def getPolys()
        @polys
    end

    def encode(char)
        (char.ord & 0x1f) + ((char.ord ^ 0x20) & 0x20)
    end

    def decode(int)
        int + 0x20
    end

    def binaryToPoly(binary)
        binaryArray = binary.to_s(2).split(//)
        binaryArray = binaryArray.map! {|x| x.to_i}
        binaryArray = binaryArray.reverse
        Polynomial[binaryArray]
    end

    def polyToBinary(poly)
        coefs = poly.coefs
        coefs = coefs.reverse
        coefs = coefs.map! {|x| x.to_s}
        binary = coefs.join
        binary.to_i(2)
    end

    # Addition of two encoded characters
    def add(ec1, ec2)
        ec1 ^ ec2
    end

    def multiply(ec1, ec2)
        poly1 = binaryToPoly(ec1)
        poly2 = binaryToPoly(ec2)

        product = multiplyPolys(poly1, poly2)

        polyToBinary(product)
    end

    # multiplies 2 polynomials with coefs in Z2
    def multiplyPolys(poly1, poly2)
        newPoly = poly1.*(poly2)

        newPoly = mod2(newPoly)
        newPoly = reduce(newPoly)
        newPoly = mod2(newPoly)
        
        newPoly
    end

    # reduce the degree of a polynomial using the fact that x^6 = x + 1
    def reduce(poly)
        degree = poly.degree()
        newPoly = poly

        while degree > 5 do
            newPoly = reduceHelper(newPoly, degree)
            degree = newPoly.degree()
        end

        newPoly
    end

    def reduceHelper(poly, degree)
        replacement = @replacements[degree - 6]
        newPoly = poly.-(@polys[degree - 6])
        newPoly.+(replacement)
    end

    # despite what this terrible name implies, all this function does
    # is set all even coefficients to 0.
    def mod2(poly)
        coefs = poly.coefs.dup
        coefs = coefs.map! {|x| x % 2}
        Polynomial[coefs]
    end

end


encoder = Encoder.new

vc = encoder.getValidCharacters
replacements = encoder.getReplacements

print "  "
vc.each do |x|
    print x + " "
    
end

puts

vc.each do |x|
    xBin = encoder.encode(x)
    print x
    vc.each do |y|
        yBin = encoder.encode(y)
        product = encoder.multiply(xBin, yBin)
        print " " + encoder.decode(product).chr
    end
    puts
end


