#!/usr/bin/env ruby

require "rubygems"
require "polynomial"
require "./Encoder"

## This class will handle the Addition/Multiplication/Division of
## elements in the field F64. Which are represented as degree 5
## polynomials of the form: a0 + a1 x + a2 x^2 + a3 x^3 + a4 x^4 + a5 x^5
## where ai is either 0 or 1. These elements are the coefficents of
## the elements of F64[x], which is the ring we are working in.

class CoefficientArithmetic
    
    def initialize()
        super()
        
        @encoder = Encoder.new()
        
        @validCharacters = @encoder.getValidCharacters()

        # These are the polynomials which get replaced since they are higher
        # Than degree 5.
        @polys = [Polynomial.new(0,0,0,0,0,0,1), Polynomial.new(0,0,0,0,0,0,0,1), 
                  Polynomial.new(0,0,0,0,0,0,0,0,1), Polynomial.new(0,0,0,0,0,0,0,0,0,1), 
                  Polynomial.new(0,0,0,0,0,0,0,0,0,0,1)]        
        
        # These are the polynomials which we replace the above polynomials with.
        @replacements = [Polynomial.new(1, 1), Polynomial.new(0, 1, 1), 
                         Polynomial.new(0, 0, 1, 1), Polynomial.new(0, 0, 0, 1, 1), 
                         Polynomial.new(0, 0, 0, 0, 1, 1)]
                         
        # This is an inverse lookup table. It maps an element to its multiplicative inverse.
        @inverses = generateInverses()
    
    end

    def getReplacements()
        @replacements
    end

    def getPolys()
        @polys
    end
    
    def getValidCharacters()
        @validCharacters
    end
    
    # It is not neccessary to convert the binary strings to a polynomial to add them.
    def addEncoded(char1, char2)
        char1 ^ char2
    end

    # Add two elements
    def binaryAdd(char1, char2)
        encodedChar1 = @encoder.encode(char1)
        encodedChar2 = @encoder.encode(char2)
        result = addEncoded(encodedChar1, encodedChar2)
        @encoder.decode(result).chr
    end
    
    # Takes a list of elements and adds them.
    def add(chars)
        result = chars[0]
        
        for i in 1...chars.length
            result = binaryAdd(result, chars[i])
        end
        
        result
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
    
    # To multiply we do need to convert the binary strings to polynomials
    def multiplyEncoded(ec1, ec2)
        poly1 = binaryToPoly(ec1)
        poly2 = binaryToPoly(ec2)

        product = multiplyPolys(poly1, poly2)

        polyToBinary(product)
    end

    # Multiplies two elements
    def binaryMultiply(char1, char2)
        encodedChar1 = @encoder.encode(char1)
        encodedChar2 = @encoder.encode(char2)
        result = multiplyEncoded(encodedChar1, encodedChar2)
        @encoder.decode(result).chr
    end
    
    # Takes a list of elements and multiplies them
    def multiply(chars)
        result = chars[0]
        
        for i in 1...chars.length
            result = binaryMultiply(result, chars[i])
        end
        
        result
    end

    # multiplies 2 polynomials with coefs in Z(2^m)
    def multiplyPolys(poly1, poly2)
        newPoly = poly1.*(poly2)

        newPoly = modX(newPoly, 2)
        newPoly = reduce(newPoly)
        newPoly = modX(newPoly, 2)
        
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
    
    # This method raises a character to a given power
    def exp(char, power)
        toReturn = char
        
        for i in 2..power
            toReturn = multiply(toReturn, char)
        end
        
        toReturn
    end

    # This function does reduces the coefficients mod x
    def modX(poly, mod)
        coefs = poly.coefs.dup
        coefs = coefs.map! {|x| x % mod}
        Polynomial[coefs]
    end

    # This method is given a character
    def isPrimitive(char)
        puts char
        
        count = 1
        current = multiplyEncoded(char, char)
        while current != char do
            puts current
            current = multiplyEncoded(current, char)
            count += 1
        end

        puts "The count was: " + count.to_s

    end
    
    # This method creates a Hashmap of multiplicative inverses
    def generateInverses()
        toReturn = Hash.new()
        
        @validCharacters.each do |x|
            @validCharacters.each do |y|
                if (multiply([x,y]) == '!')
                    toReturn[x] = y
                    break
                end
            end
        end
        
        toReturn
    end
    
    # This method finds the inverse by looking it up in the table
    def findInverse(char)
        @inverses[char]
    end
    
    # This method divides two elements (by multiplying by the inverse of the divisor)
    def binaryDivide(dividend, divisor)
        inverse = findInverse(divisor)
        multiply([dividend, inverse])
    end 

    # Prints a Multiplication Table
    def printMultTable()
        print "  "
        @validCharacters.each do |x|
            print x + " "
            
        end

        puts

        @validCharacters.each do |x|
            xBin = @encoder.encode(x)
            print x
            @validCharacters.each do |y|
                yBin = @encoder.encode(y)
                product = multiplyEncoded(xBin, yBin)
                print " " + @encoder.decode(product).chr
            end

            puts
        end
    end

    # Prints an Addition Table
    def printAddTable()
        print "  "
        @validCharacters.each do |x|
            print x + " "
            
        end

        puts

        @validCharacters.each do |x|
            xBin = @encoder.encode(x)
            print x
            @validCharacters.each do |y|
                yBin = @encoder.encode(y)
                product = addEncoded(xBin, yBin)
                print " " + @encoder.decode(product).chr
            end

            puts
        end
    end

end
