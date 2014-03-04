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

    # Addition of two encoded characters
    def add(ec1, ec2)
        ec1 ^ ec2
    end

    # reduce the degree of a polynomial using the fact that x^6 = x + 1
    def reduce(poly)
        degree = poly.degree()
        newPoly = Polynomial.new()

        while degree > 5 do
            newPoly = reduceHelper(poly, degree)
            degree = newPoly.degree()
        end

        newPoly
    end

    def reduceHelper(poly, degree)
        replacement = @replacements[degree - 6]
        newPoly = poly.-(@polys[degree - 6])
        newPoly.+(replacement)
    end

end


encoder = Encoder.new

vc = encoder.getValidCharacters
replacements = encoder.getReplacements

vc.each do |x|
    #var = encoder.encode(x)
    #puts x + " " + var.to_s() + " " + encoder.decode(var).chr
end

p encoder.reduceHelper(Polynomial.new(1,1,0,0,0,0,0,0,1), 8).to_s
