<?php
//お決まりのやつ
echo "Hello, World!\n";
echo "This is the second PHP script!\n";
echo date_format(new DateTime(), 'Y-m-d-H-i-s-v') . "\n";
//sum関数の定義
function sum($int1,$int2) {
  return
$int1 + $int2;
}
$num = sum(8,9);
echo $num . "\n";
//配列の定義
$fruits = array("apple","orange","banana");
//配列の中身を表示
foreach($fruits as $fruit) {
  echo $fruit . "\n";
} 
//連想配列の定義
$fruits = array("apple" => 100, "orange" => 80, "banana" => 60);
//連想配列の中身を表示
foreach($fruits as $key => $value) {
  echo $key . " is " . $value . " yen.\n";
}
//連想配列の中身を表示
foreach($fruits as $key => $value) {
  echo $key . " is " . $value . " yen.\n";
}

//条件分岐
$age = 18;
 
if ($age >= 20){
  echo 'あなたの年齢は20歳以上ですね！'. "\n";
} else {
  echo 'あなたの年齢は20歳未満ですね！'. "\n";
}

//繰り返し処理
for ($i = 0; $i < 10; $i++) {
  echo $i . "\n";
}







?>
