STEP 4:
	利用 add, sub 實作加跟減
	利用 mult mflo 實作乘法
	利用 div mflo 實作除法，商數是存在lo (要注意除數是0的狀況，是的話直接跳到ret)
STEP 5:
	int 變成 string 的方法是把 int 一直除以10，餘數就是要 output 的數字(要記得加上'0'才會是對的char)，商再繼續當被除數
	因此要寫一個類似 for(int i = 0; i < 4; i++) 的迴圈

編寫平台：Mac