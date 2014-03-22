# -*- encoding: utf-8 -*-

require './real-coded_GA.rb'
require './evaluation_func.rb'

GEN_MAX = 300
ORDER   = 2
EPS     = 0.001

eval = PolynomialFit.new
eval.push(2.0, 1.0)
eval.push(1.0, 2.0)
eval.push(4.0, 1.0)
eval.push(2.0, 4.0)
eval.show

ga = RealCodedGA.new(ORDER)
ga.seed(-10.0, 10.0)

(1..GEN_MAX).each_with_index do |i|
	totalFitness, bestParam = ga.run(eval, i)
	break if totalFitness < EPS
end
