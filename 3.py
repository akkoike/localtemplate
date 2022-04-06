# 文字列連結
print (",".join(("koike", "akira", "test")))

# 小文字　大文字 最初だけ大文字
print ("HELLO".lower())
print ("heLLo".upper())
print ("heLLo".capitalize())

# 数字の判定 (１文字以上で10進数かどうか）
print("1230".isdecimal())   # Trueを返す

# 文字列が含まれている場合は、その配列番号を返す、無ければ-1を返す
print ("koike".find("oi"))
print ("koike".find("ik"))
print ("koike".find("aki"))

# findと同じだが、見つからなかったらエラーを返したい場合
#print ("koike".index("aki"))

# 同じ文字列が重複せずに何回使われているかを数える
print ("koike".count("o"))
print ("koikeoi".count("o"))
print ("koike".count("aki"))

# デリミタを指定した分割して表示
print ("koike,akira,test".split(","))   # ['koike', 'akira', 'test']
print ("koike,,,akira,test".split(","))   # ['koike', '', '', 'akira', 'test']

# 改行が入った文字列を配列にする
str1 = """koike
akira
test"""

print(str1)
print(str1.splitlines())