# -*- encoding: utf-8 -*-

# -----------------------------------------------------
#    多項式フィッティング
# -----------------------------------------------------
class PolynomialFit
	# 評価関数の重み
	W = 1.0

	def initialize
		@dataX = Array.new
		@dataY = Array.new
	end

	def push(x, y)
		@dataX.push(x)
		@dataY.push(y)
	end

	def show
		print("\n---------- Test Data ----------\n")
		print("idx\t \tx\ty\n\n")

		@dataX.zip(@dataY).each_with_index do |data, idx|
			x = data[0]
			y = data[1]
			print("#{idx}\t|\t#{x}\t#{y}\n")
		end
	end

	# パラメータのセットに対する評価関数の値(適合度)を求める
	def fitness(param)
		fit = 0.0 # 適合度

		@dataX.zip(@dataY).each do |x, y|
			ye = 0.0

			# xの関数形は多項式とする
			# 多項式の次数はparamの数によって決まる
			param.each_with_index do |p, i|
				ye += p * x ** i
			end

			fit += 0.5 * W * (y - ye) * (y - ye)
		end

		return fit
	end
end
