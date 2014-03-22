# -*- encoding: utf-8 -*-

# -----------------------------------------------------
#    個体集合
# -----------------------------------------------------
class Population
	attr_reader :totalFitness, :bestParam

	# sizePop  : 個体数
	# sizeParam: 各個体のパラメータ数
	# rndBegin : パラメータの下限
	# rndEnd   : パラメータの上限
	def initialize(sizePop, sizeParam, rndBegin = 0.0, rndEnd = 1.0)
		# 個体の集合
		@pop = Array.new(sizePop) { Array.new(sizeParam) { rand(rndBegin...rndEnd) } }

		# 個体の適合度
		@fit = Array.new(sizePop, 0.0)

		# 個体集合全体の適合度
		@totalFitness = 0.0

		# 最良個体
		@bestParam = Array.new
	end

	def shuffle!
		@pop.shuffle!
	end

	def slice!(idx, len)
		return @pop.slice!(idx, len)
	end

	def push(param)
		@pop += param
	end

	def calc_fit(eval)
		@pop.each_with_index do |param, idx|
			@fit[idx] = eval.fitness(param)
		end

		# 集団全体の適合度の算出
		total_fit

		# 最良個体の算出
		best_fit
	end

	def show(gen)
		print("\n\n---------- Population [generation = #{gen}] ----------\n")
		print("idx\t \tparams\n\n")

		@pop.zip(@fit).each_with_index do |zip, idx|
			param = zip[0]
			f     = zip[1]

			print("#{idx}\t|")

			param.each do |g|
				print("\t#{g}")
			end

			if gen > 0
				print("\t|\t#{f}\n")
			else
				print("\n")
			end
		end

		print("\n[total fitness]\n#{totalFitness}\n") if gen > 0
	end


	private


	def total_fit
		@totalFitness = 0.0

		@fit.each do |f|
			@totalFitness += f
		end
	end

	def best_fit
		minimum = Float::INFINITY

		@pop.zip(@fit).each do |param, f|
			if f < minimum
				@bestParam = param
				minimum    = f
			end
		end
	end
end


# -----------------------------------------------------
#    実数値GA
#     - 世代交代モデル: Minimal Generation Gap (MGG)
#     - 交叉方法: Simplex Crossover (SPX)
# -----------------------------------------------------
class RealCodedGA
	# order: 近似曲線の次数
	def initialize(order)
		@m    = order + 1  # 各個体のパラメータの数
		@nPOP = 15 * @m    # 初期集団に属する個体の数
		@nP   = @m + 1     # 交叉の対象となる親個体の数
		@nCH  = 10 * @m    # 交叉によって生成される子個体の数
	end

	# 初期集団を乱数で生成する
	def seed(rndBegin = 0.0, rndEnd = 1.0)
		@population = Population.new(@nPOP, @m, rndBegin, rndEnd)
		@population.show(0)
	end

	# 実数値GAの実行
	def run(eval, gen)
		# 交叉対象の選択
		select

		# 交差
		crossover

		# 世代交代
		evolve(eval)

		# 適合度の算出
		@population.calc_fit(eval)

		@population.show(gen)

		return @population.totalFitness, @population.bestParam
	end


	private


	# 親個体を個体集合からランダムに選択する
	def select
		@population.shuffle!
		@parent = @population.slice!(0, @nP)
	end

	# 交叉によって子個体を生成する
	def crossover
		@child = Array.new
		@nCH.times do
			@child << simplex_crossover
		end
	end

	# 世代交代を行う
	def evolve(eval)
		# 「世代交代の候補」 = 「子個体」 + 「親個体からランダムに2個」
		@parent.shuffle!
		@candidate  = @parent.slice!(0, 2)
		@candidate += @child

		# 世代交代の候補からエリートを選択する
		elite    = select_elite(eval)

		# 世代交代の候補(エリートは除く)からルーレット選択を行う
		roulette = select_roulette

		# 親個体に戻す
		@parent << elite
		#@parent << roulette
		@parent << elite

		# 次世代の集団を生成する
		@population.push(@parent)
	end

	# シンプレックス交叉
	def simplex_crossover
		# 重心の計算
		g = Array.new(@m, 0.0)
		for i in 0..@m-1
			for k in 0..@nP-1
				g[i] += @parent[k][i]
			end
		end
		g.map! { |x| x / @nP }
		
		z = Array.new(@nP) { Array.new(@m, 0.0) }
		for i in 0..@m-1
			for k in 0..@nP-1
				z[k][i] = g[i] + Math.sqrt(@m + 2) * (@parent[k][i] - g[i])
			end
		end

		c = Array.new(@nP) { Array.new(@m, 0.0) }
		for i in 0..@m-1
			for k in 1..@nP-1
				c[k][i] = (z[k-1][i] - z[k][i] + c[k-1][i]) * rand(0.0..1.0) ** (1.0 / (1.0 + (k-1).to_f))
			end
		end

		child = Array.new(@m, 0.0)
		for i in 0..@m-1
			child[i] = z[@nP-1][i] + c[@nP-1][i]
		end

		return child
	end

	# エリート(最良個体)選択
	def select_elite(eval)
		elite   = []
		delIdx  = 0
		minimum = Float::INFINITY

		@candidate.each_with_index do |param, idx|
			fit = eval.fitness(param)

			if fit < minimum
				elite   = param
				minimum = fit
				delIdx  = idx
			end
		end

		@candidate.delete_at(delIdx)

		return elite
	end

	# ルーレット選択(未実装)
	def select_roulette
		return @candidate.sample
	end
end
