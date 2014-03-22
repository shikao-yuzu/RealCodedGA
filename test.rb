# -*- encoding: utf-8 -*-

require './real-coded_GA.rb'
require './evaluation_func.rb'

# 世代数の上限
GENERATION_MAX = 100

# 各個体の遺伝子の数
GENE_NUM = 2

# 初期世代の遺伝子の範囲
GENE_MIN = -10.0
GENE_MAX = 10.0

# 終了条件
EPS = 0.00001


# テストデータ
eval = PolynomialFit.new
eval.push(2.0, 1.0)
eval.push(1.0, 0.5)
eval.push(3.0, 3.0)
eval.push(2.0, 2.0)
eval.push(4.0, 6.0)
eval.push(3.0, 5.0)
eval.push(3.5, 6.5)
eval.push(4.0, 10.0)
eval.show


# 実数値GA
ga = RealCodedGA.new(GENE_NUM)
ga.seed(GENE_MIN, GENE_MAX)

(1..GENERATION_MAX).each do |i|
	totalFit, bestGene = ga.run(eval, i)
	break if totalFit < EPS
end
