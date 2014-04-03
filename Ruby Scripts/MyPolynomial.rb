#!/usr/bin/env ruby

require "rubygems"
require "polynomial"
require "./CoefficientArithmetic.rb"

## This class is a polynomial class which uses elements in F64 as coefficients.
## Note: A LOT of this code was pulled from the Polynomial gem created 
## by Adriano Mitre. I just changed it where I needed to. 
## Find the original here: http://adrianomitre.github.io/Polynomial/website/index.html

class MyPolynomial < Polynomial

    def initialize(*coefs)
        @ca = CoefficientArithmetic.new()
        
        case coefs[0]
        when Hash
            coefs = self.class.coefs_from_pow_coefs(coefs[0])
        else
            coefs.flatten!
            if coefs.empty?
                raise ArgumentError, 'at least one coefficient should be supplied'
            elsif !coefs.all? {|c| @ca.getValidCharacters.include? c }
                raise TypeError, 'non-valid coefficient supplied'
            end
        end
        @coefs = MyPolynomial.remove_trailing_zeroes(coefs)
        @coefs.freeze
    end
    
    def substitute(x)
        total = @coefs.last
        @coefs[0..-2].reverse.each do |a|
            product = @ca.multiply([total, x])
            total = @ca.add([product, a])
        end
        total
    end
    
    # Addition
    def +(other)
        case other
            when (@ca.getValidCharacters.include? other)
                ca.add([self, MyPolynomial.new(other)])
            else
                small, big = [self, other].sort
                a = big.coefs.dup
                for n in 0 .. small.degree
                    a[n] = @ca.add([a[n], small.coefs[n]])
                end
                MyPolynomial.new(a)
        end
    end
    
    # Multiplication
    def *(other)
        case other
            when (@ca.getValidCharacters.include? other)
                result_coefs = @coefs.map {|a| @ca.multiply([a, other])}
            else
                result_coefs = [' '] * (self.degree + other.degree + 2)
                for m in 0 .. self.degree
                    for n in 0 .. other.degree
                        product = @ca.multiply([@coefs[m], other.coefs[n]])
                        result_coefs[m+n] = @ca.add([result_coefs[m+n], product])
                    end
                end
        end
        p result_coefs
        puts
        MyPolynomial.new(result_coefs)
    end
    
    # Division. Returns a list of the quotient and the remainder
    def divmod(divisor)
        case divisor
            when (@ca.getValidCharacters.include? other)
              new_coefs = @coefs.map do |a|
                  quotient = @ca.binaryDivide(a, divisor)
              end
              q, r = MyPolynomial[new_coefs], MyPolynomial[' ']
            when MyPolynomial
              a = self; b = divisor; q = ' '; r = self
              (a.degree - b.degree + 1).times do
                dd = r.degree - b.degree
                qqa = @ca.binaryDivide(r.coefs[-1], b.coefs[-1])
                qq = Polynomial[dd => qqa]
                q = @ca.add([q, qq])
                r = @ca.add([r, @ca.multiply([qq, divisor])])
                break if r.zero?
              end
            else
              raise ArgumentError, 'divisor should be a valid character or polynomial'
        end
        [q, r]
    end
    
    # Division. Just returns the quotient
    def div(other)
        divmod(other).first
    end
    alias / div
    
    # Mod. Does division, just returns the remainder
    def %(other)
        divmod(other).last
    end
    
    def self.remove_trailing_zeroes(ary)
        m = 0
        ary.reverse.each.with_index do |a,n|
            unless (a == ' ')
                m = n+1
                break
            end
        end
        ary[0..-m]
    end
    
    def self.coefs_from_pow_coefs(hash, params={})
        power_coefs = Hash.new(' ').merge(hash)
        (0..power_coefs.keys.max).map {|p| power_coefs[p] }
    end
    
    def to_s(params={})
    params = ToSDefaults.merge_abbrv(params)
    mult = params[:multiplication_symbol]
    pow = params[:power_symbol]
    var = params[:variable_name]
    coefs_index_enumerator = if params[:decreasing]
                               @coefs.each.with_index.reverse_each
                             else
                               @coefs.each.with_index
                             end
    result = ''
    coefs_index_enumerator.each do |a,n|
      next if (a == ' ') && degree > 0 && !params[:verbose]
      result += '+' unless result.empty?
      coef_str = a.to_s
      coef_str = '(' + coef_str + ')' if coef_str[/[+\/]/]
      result += coef_str unless a == 1 && n > 0
      result += "#{mult}" if a != 1 && n > 0
      result += "#{var}" if n >= 1
      result += "#{pow}#{n}" if n >= 2
    end
    #result.gsub!(/\+-/,'-') <-- This line was messing up the output when '-' was a coefficient
    result.gsub!(/([^e\(])(\+|-)(.)/,'\1 \2 \3') if params[:spaced]
    result
  end

  # Returns true if all the coefficients are ' '
  def zero?
    toReturn = true
  
    @coefs.each do |coef|
        if coef != ' '
            toReturn = false
            break
        end
    end
  end

end
