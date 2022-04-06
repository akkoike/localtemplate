#関数の定義と利用
def mypoint(str1, num1):
    result = "My name is %-10s, point is %5d." % (str1,num1)
    print(result)

mypoint("koike",46)

# 出力時の変換
num2=20
print("10真数では %d , 16進数では %x です" % (num2,num2))

name = "koike"
old = 46
print("1, 名前は{:<8s}です、年齢は{:<3d}です".format(name,old))
print("2, 名前は{0}です、年齢は{1}です。".format("小池",46))
print("3, 名前は{namae}です、年齢は{years}です。".format(namae="小池",years=46))
print("4, 名前は{:s}です、年齢は{:d}です。".format("小池",46))
print(f"5, 名前は{name:s}です、年齢は{old:d}です。")

# 数値のカンマ区切り
print ("{:,d}".format(1000000))