import xml2js from 'react-native-xml2js/lib/parser';
import {
	Component
} from 'react';

import {
	NativeModules,
} from 'react-native';



// var URL_API_HOST = "http://10.1.3.90:8081/tisp/index.php?r="
// var URL_API_IMAGE = "http://10.1.3.90:8081/tcm";
// var STRIPE_PK_LIVE = 'pk_test_51J2RALDOZGW531kA4P9Hed5lkH5ldQ7dfZipqVbKUSTNRP4iu5ch2DQyvekxmOFyiLWlPiybjtuxfHxvWvTZXo2f00Kl6UhnVd';



var UEL_API_END_HOST = "/ws&ws=1";

export default class WebserviceUtil extends Component {

	

	static getQueryDataResponse(methodName,dataResponse,vaule, callback) {
		
		var URL_API_HOST = NativeModules.NativeBridge.URL_API_HOST;
		
		let datajson;

//		var url = 'http://tispdemo.performsoftware.biz/index.php?r=query/ws&ws=1';
		NativeModules.NativeBridge.log("value:"+vaule);
		var url = URL_API_HOST + methodName  + UEL_API_END_HOST;
		
		var xmlHttp = new XMLHttpRequest();; //获取XMLHttpRequest对象var

		xmlHttp.open('POST', url, true); //异步请求数据
		xmlHttp.onreadystatechange = function() {

			if (xmlHttp.readyState == 4) {

				try {
					if (xmlHttp.status == 200) {

						var response = xmlHttp.responseText;


						 //console.error(response);

						xml2js.parseString(response, (err, res) => {


							var json = res["SOAP-ENV:Envelope"]["SOAP-ENV:Body"][0]["ns1:" + dataResponse ][0]["return"][0]["_"];

							datajson = JSON.parse(json,'utf-8');
							NativeModules.NativeBridge.log("\n"+"url:"+url+"\n"+"response:"+JSON.stringify(datajson));
							callback(datajson);

						})

					} else {
						callback(datajson);
					}
				} catch (e) {
					callback(datajson);
				}
			}
		}
		xmlHttp.setRequestHeader('Content-Type', 'application/json; charset=utf-8'); //设置请求头的ContentType
		xmlHttp.setRequestHeader('SOAPAction', 'urn:QueryControllerwsdl' + 'getQueryData'); //设置SOAPAction
		xmlHttp.send(vaule); //发送参数数据
	}


	static getImageHostUrl(){

		return NativeModules.NativeBridge.URL_API_IMAGE;
	}


	static getStripePkLive(){
		
		return NativeModules.NativeBridge.STRIPE_PK_LIVE;
	}


}