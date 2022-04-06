# エンコード
# coding: utf_8

str3 = "Hello, World"
print (str3)

# 変数
num1=1; num2=2; num3=3
print (num1 + num2 + num3)

"""
\を使った行の繋ぎ
"""
num4=4 ; num5=5; num6\
    =6; num7=7
print (num4 + num5 + num6 + num7)

print ("こんにちは")

msg_a = """\
複数行にわたる文字列の
格納方法
です。"""
print(msg_a)

# エスケープを文字列全体で認識してほしい場合(以下２つは同じ)
print (r"インストール先はc:\programfiles\hogehoge です")
print ("インストール先はc:\\programfiles\\hogehoge です")

# 文字列結合
str1 = "hogehoge"
str2 = "fugafuga"
print (str1 + str2)
print (str1 * 4)

# 文字列と数値
num = 18
print (str1 + str(num))

# 文字列の長さ
len(str1)
print (str(len(str1)))

# インデックス値
str5 = "hello"
print (str5[1])     # e
print (str5[-1])    # o
print (str5[1:4])   # ell
print (str5[1:])    # ello
print (str5[:4])    # hell
