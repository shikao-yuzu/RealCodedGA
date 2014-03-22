# -*- encoding: utf-8 -*-

require './real-coded_GA.rb'
require './evaluation_func.rb'

# 世代数の上限
GENERATION_MAX = 100

# 各染色体の遺伝子の数
GENE_NUM = 2

# 初期世代の遺伝子の範囲
GENE_MIN = -10.0
GENE_MAX = 10.0

# 終了条件
EPS = 1.0

# 評価関数
eval = PolynomialFit.new
eval.push(2.0, 1.0)
eval.push(1.0, 2.0)
eval.push(4.0, 1.0)
eval.push(2.0, 4.0)
eval.show

# 実数値GA
ga = RealCodedGA.new(GENE_NUM)
ga.seed(GENE_MIN, GENE_MAX)

(1..GENERATION_MAX).each_with_index do |i|
	totalFitness, bestParam = ga.run(eval, i)
	break if totalFitness < EPS
end
