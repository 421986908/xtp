#include <string>
#include <map>
#include <iostream>

#include "xtp_quote_api.h"
#include "quote_spi.h"

bool is_connected_ = false;
XTP_PROTOCOL_TYPE quote_protocol = XTP_PROTOCOL_UDP;

int main()
{
	//初始化行情api
	XTP::API::QuoteApi* pQuoteApi = XTP::API::QuoteApi::CreateQuoteApi(1, "F:\\xtp\\bin\\win\\");
	MyQuoteSpi* pQuoteSpi = new MyQuoteSpi();
	pQuoteApi->RegisterSpi(pQuoteSpi);

	//设定行情服务器超时时间，单位为秒
	pQuoteApi->SetHeartBeatInterval(110); //此为1.1.16新增接口
														 //设定行情本地缓存大小，单位为MB
	pQuoteApi->SetUDPBufferSize(1024);//此为1.1.16新增接口

	int loginResult_quote = -1;
	//登录行情服务器,自1.1.16开始，行情服务器支持UDP连接，推荐使用UDP
	loginResult_quote = pQuoteApi->Login("120.27.164.138", 6002, "15042285" , "CG2ssKP1", quote_protocol);
	if (loginResult_quote == 0)
	{
		//从配置文件中读取需要订阅的股票
		char* *allInstruments = new char*[1];
		for (int i = 0; i < 1; i++) {
			allInstruments[i] = new char[7];
			strcpy(allInstruments[i], "000016");
		}

		//开始订阅
		pQuoteApi->SubscribeMarketData(allInstruments, 1, XTP_EXCHANGE_SH);

		//释放
		for (int i = 0; i < 1; i++) {
			delete[] allInstruments[i];
			allInstruments[i] = NULL;
		}

		delete[] allInstruments;
		allInstruments = NULL;
	}
	else
	{
		//登录失败，获取失败原因
		XTPRI* error_info = pQuoteApi->GetApiLastError();
		std::cout << "Login to server error, " << error_info->error_id << " : " << error_info->error_msg << std::endl;

	}

	//主线程循环，防止进程退出
	while (true)
	{
#ifdef _WIN32
		Sleep(1000);
#else
		sleep(1);
#endif // WIN32

	}
	return 0;
}
