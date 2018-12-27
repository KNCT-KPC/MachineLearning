# -*- coding: utf-8 -*-

# vender_machine.rb
# Q学習によって自販機を操作する際のQ値の変動を観測するRubyスクリプト

# Q値表を初期化
def initialize_qtable(num_s, num_a)
	return Array.new(num_s){ Array.new(num_a, 0.0) }
end

# ε-グリーディ法
def epsilon_greedy(epsilon, qtable, s, num_a)
	x = rand(100)
  	if x < epsilon*100 then
	    act = select_action(num_a)
  	else
	    act = select_best_action(qtable, s, num_a);
	end
	return act # 戻り値はq値表中の, 状態sの番号
end

# 最良となる行動を選択する
def select_best_action(qtable, s, num_a)
	imax = [0]           # Q値が最大となる行動の番号を詰め込む配列(行動[0]で仮の最大値の番号を代入)
  	max = qtable[s][0]   # Q値の最大値(行動[0]で仮の最大値を代入)
  	num_max = 1          # Q値の最大値の個数(行動[0]が代入されているので1)

	for i in 1...num_a
	    if max < qtable[s][i] then
	     	max = qtable[s][i]
    	  	imax[0] = i
      		num_max = 1
    	elsif max == qtable[s][i] then
      		imax.push(i)
      		num_max += 1
      	end
  	end

  	return imax.sample # 戻り値は, 状態sに於ける, Q値が最大となる行動の番号群imaxの内の1つ
end

# 行動を無作為に選択する
def select_action(num_a)
	return rand(num_a)
end



# 状態sでの最大のq値を返す
def max_qval(qtable, s, num_a)
	value = 0.0
	for i in 0...num_a
		if value < qtable[s][i] then
			value = qtable[s][i]
		end
	end
	return value
end

# Q値を更新する
def update_q(q, reward, qmax, epsilon, alpha, gamma)
	return (1 - alpha) * q + alpha * (reward + gamma * qmax)
end

# vending_machine
def vending_machine(s, a, sd)
	reward = 0.0

	if s == 0 && a == 0 then    # 電源offの時にボタン1を押した
    	$sd = 1
    elsif s == 0 && a == 1 then # 電源offの時にボタン2を押した
    	$sd = 0
  	elsif s == 1 && a == 0 then # 電源onの時にボタン1を押した
    	$sd = 0
  	elsif s == 1 && a == 1 then # 電源onの時にボタン2を押した
    	$sd = 1
    	reward = 10.0
  	end

	return reward
end

num_s = 2 # 状態の数 num_s
num_a = 2 # 行動の数 num_a
reward = 0.0  # 報酬 reward

s = 0     # 現状態 s
$sd = 0   # 次状態 sd
a = 0     # 行動   a 

qtable = initialize_qtable(num_s, num_a) # Q値表

alpha = 0.1   # 学習率α
gamma = 0.9   # 割引率γ
epsilon = 0.2 # ε-グリーディ法の適用割合

for i in 1..50
	# 行動を決定
	#a = select_action(num_a)
	#a = select_best_action(qtable, s, num_a)
	a = epsilon_greedy(epsilon, qtable, s, num_a)

	# 次状態と報酬を決定
	reward = vending_machine(s, a, $sd)

	# 最大値を探索
	qmax = max_qval(qtable, $sd, num_a)

	# 状態sと行動aに関するQ値を更新する
    qtable[s][a] = update_q(qtable[s][a], reward, qmax, epsilon, alpha, gamma)

    # 出力する
	print("s = ", s, ", a = ", a, ", sd = ", $sd, ", r = ", reward, "\n")
	print("qtable[", s, "][", a, "] = ", qtable[s][a], ", reward = ", reward, ", qmax = ", qmax, "\n")

	# 次状態に遷移する
	s = $sd
end

puts ""
for i in 0...num_s
	for j in 0...num_a
		print "qtable[", i, "][", j, "] = ", qtable[i][j], " "
	end
	puts ""
end

=begin
for i in 0...num_s
	for j in 0...num_a
		reward = vending_machine(i, j, $sd)
		print("s = ", i, ", a = ", j, ", sd = ", $sd, ", r = ", reward, "\n")
	end
end
=end


