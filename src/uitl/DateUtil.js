import {
	Component
} from 'react';

import MD5 from "react-native-md5";


export default class DateUtil extends Component {

	static formatDateTime() {
		let date = new Date();
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		var h = date.getHours();
		h = h < 10 ? ('0' + h) : h;
		let minute = date.getMinutes();
		let second = date.getSeconds();
		minute = minute < 10 ? ('0' + minute) : minute;
		second = second < 10 ? ('0' + second) : second;
		return y + '-' + m + '-' + d + ' ' + h + ':' + minute + ':' + second;
	}


	static formatDateTime0(timestamp){
		let date = new Date(timestamp);
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		var h = date.getHours();
		h = h < 10 ? ('0' + h) : h;
		let minute = date.getMinutes();
		let second = date.getSeconds();
		minute = minute < 10 ? ('0' + minute) : minute;
		second = second < 10 ? ('0' + second) : second;
		return y + '-' + m + '-' + d + ' ' + h + ':' + minute + ':' + second;

	}



	// 获取当天时间
	static formatDateTime1() {
		let date = new Date();
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		var h = date.getHours();
		h = h < 10 ? ('0' + h) : h;
		return y + '-' + m + '-' + d;
	}

	// 获取当天时间
	static formatDateTime2() {
		let date = new Date();
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		var h = date.getHours();
		h = h < 10 ? ('0' + h) : h;
		return y + '-' + m ;
	}




	// 获取后几天时间
	static formatDateTime5(nextime) {

		let curDate = new Date();
		let date = new Date(curDate.getTime() + nextime);
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		var h = date.getHours();
		h = h < 10 ? ('0' + h) : h;
		return y + '-' + m + '-' + d;
	}



	static formatDateTime2(timestamp) {

		var date = new Date(timestamp * 1000); //时间戳为10位需*1000，时间戳为13位的话不需乘1000
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		return y + '-' + m;
	}

	// 判断 2008-04-02 10:08:44 时间类型 是否是当天
	static isToday(timestamp){


		return DateUtil.formatDateTime1() == DateUtil.parserDateString(timestamp);

	}




	static formatDateTime3(timestamp) {

		var date = new Date(timestamp * 1000); //时间戳为10位需*1000，时间戳为13位的话不需乘1000
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		return y;
	}



	//2008-04-02 10:08:44 时间类型 转 2008-04-02
	static formatDateTime4(timestamp) {
		let date = DateUtil.parserDateString(timestamp);
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		var h = date.getHours();
		h = h < 10 ? ('0' + h) : h;
		return y + '-' + m + '-' + d;
	}


	/**
     * 例如:2017-06-28 10:48:46转成2017-06-28,
     * 可把- replace成/
     * @param dateString
     * @return 2017-06-28
     */
    static parserDateString(dateString){
        if(dateString){
            let regEx = new RegExp("\\-","gi");
            let validDateStr=dateString.replace(regEx,"/");
            let milliseconds=Date.parse(validDateStr);
            let date = new Date(milliseconds);
            let y = date.getFullYear();
			let m = date.getMonth() + 1;
			m = m < 10 ? ('0' + m) : m;
			let d = date.getDate();
			d = d < 10 ? ('0' + d) : d;
			var h = date.getHours();
			h = h < 10 ? ('0' + h) : h;
			return y + '-' + m + '-' + d;

        }
    }

	static formatDateTime4(timestamp) {

		var date = new Date(timestamp * 1000); //时间戳为10位需*1000，时间戳为13位的话不需乘1000
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		return m;
	}


	static timestampToTime(timestamp) {
		var date = new Date(timestamp); //时间戳为10位需*1000，时间戳为13位的话不需乘1000
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		m = m < 10 ? ('0' + m) : m;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;

		return y + '-' + m + '-' + d;
	}


	static getENfromMoth(mongh) {

		var enName = 'Jan';

		switch (mongh) {
			case 1:
				enName = 'Jan';
				break;
			case 2:
				enName = 'Feb';
				break;
			case 3:
				enName = 'Mar';
				break;
			case 4:
				enName = 'Apr';
				break;
			case 5:
				enName = 'May';
				break;
			case 6:
				enName = 'Jun';
				break;
			case 7:
				enName = 'Jul';
				break;
			case 8:
				enName = 'Aug';
				break;
			case 9:
				enName = 'Sep';
				break;
			case 10:
				enName = 'Oct';
				break;
			case 11:
				enName = 'Nov';
				break;
			case 12:
				enName = 'Dec';
				break;
		}


		return enName;
	}


	//通过月份获取月份名称（全称）
	static getENfromMoth2(mongh) {

		var enName = 'January';

		switch (mongh) {
			case 1:
				enName = 'January';
				break;
			case 2:
				enName = 'February';
				break;
			case 3:
				enName = 'March';
				break;
			case 4:
				enName = 'April';
				break;
			case 5:
				enName = 'May';
				break;
			case 6:
				enName = 'June';
				break;
			case 7:
				enName = 'July';
				break;
			case 8:
				enName = 'August';
				break;
			case 9:
				enName = 'September';
				break;
			case 10:
				enName = 'October';
				break;
			case 11:
				enName = 'November';
				break;
			case 12:
				enName = 'December';
				break;
		}


		return enName;
	}


	//通过星期获取星期名称（简称）
	static getNamefromWeek(week){

		var enName = 'Mon';

		switch (week) {
			case 1:
				enName = 'Mon';
				break;
			case 2:
				enName = 'Tues';
				break;
			case 3:
				enName = 'Wed';
				break;
			case 4:
				enName = 'Thur';
				break;
			case 5:
				enName = 'Fri';
				break;
			case 6:
				enName = 'Sat';
				break;
			case 7:
				enName = 'Sun';
				break;
		}


		return enName;


	}






	// 获取当月有点多少天
	static getDaysfromYearMonth(year,month){

		var days = new Date(year, month, 0).getDate();
 		return days;

	}



	static transdate(endTime) {
		var date = new Date();
		date.setFullYear(endTime.substring(0, 4));
		date.setMonth(endTime.substring(5, 7) - 1);
		date.setDate(endTime.substring(8, 10));
		date.setHours(endTime.substring(11, 13));
		date.setMinutes(endTime.substring(14, 16));
		date.setSeconds(endTime.substring(17, 19));
		return Date.parse(date);
	}


	static transdate1(endTime) {
		var date = new Date();
		date.setFullYear(endTime.substring(0, 4));
		date.setMonth(endTime.substring(5, 7) - 1);
		date.setDate(endTime.substring(8, 10));
		return Date.parse(date) / 1000;
	}

	static transdate2() {
		var date = new Date();
		return Date.parse(date) / 1000;
	}

	// 生成验证码
	static randomCode(){

		var date = Date.parse(new Date()) +'' ;
		
		return date.substr(date.lenght - 4,4);

	}

	//生成UUID
	static randomUUID(){

		var date = MD5.hex_md5(Date.parse(new Date()) +'') ;
		return date.substr(0,4);


	}


	//根据时间判断星期几
	static getWeek(timedat) { //timedat参数格式：   getWeek（new Date("2017-10-27" )）

		var timedat = new Date(timedat);

		return timedat.getDay();
	}


//根据时间转换显示格式
	static getShowTimeFromDate0(){

		var date = new Date();

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return d +' ' + DateUtil.getENfromMoth(m) + ' ' + y + ', ' + DateUtil.getNamefromWeek(DateUtil.getWeek(Date.parse(date)));
	}



	//根据时间转换显示格式
	static getShowTimeFromDate(timedate){

		var date = new Date(timedate);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return d +' ' + DateUtil.getENfromMoth(m) + ' ' + y + ', ' + DateUtil.getNamefromWeek(DateUtil.getWeek(timedate));
	}





	//2021-11-18 12:00:00 转化
	static getShowTimeFromDate2(dateString){

		
		if (!dateString) {
			return '';
		}

		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
        let date = new Date(milliseconds);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return d +' ' + DateUtil.getENfromMoth(m)  + ', ' + DateUtil.getNamefromWeek(date.getDay());
	}


	static getShowTimeFromDate3(dateString){


		if (!dateString) {
			return '';
		}

		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
        let date = new Date(milliseconds);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return d +' ' + DateUtil.getENfromMoth(m)  + ' ' + y  + ', ' + DateUtil.getNamefromWeek(date.getDay());
	}


	static getShowTimeFromDate4(dateString){


		if (!dateString) {
			return '';
		}

		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
        let date = new Date(milliseconds);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return d +' ' + DateUtil.getENfromMoth(m)  + ' ' + y  ;
	}


	static getShowTimeFromDate5(dateString){

		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
        let date = new Date(milliseconds);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return DateUtil.getENfromMoth(m)  + ' ' + y  ;
	}


	static getShowTimeFromDate6(dateString){

		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
        let date = new Date(milliseconds);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return d  ;
	}


	static getShowTimeFromDate7(dateString){

		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
        let date = new Date(milliseconds);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return DateUtil.getNamefromWeek(date.getDay())  ;
	}


	// 获取时间的时间戳
	static getTimeMilliseconds(dateString){

		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
      
		return milliseconds  ;
	}




	//根据时间转换显示格式 
	static getShowTimeFromDate1(timedate){

		var date = new Date(timedate);

		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;
		return d +' ' + DateUtil.getENfromMoth(m) + ' ' + y ;
	}





	static timestampToTime1(timestamp) {
		var date = new Date(timestamp); //时间戳为10位需*1000，时间戳为13位的话不需乘1000
		let d = date.getDate();
		return d;
	}

	static dateDiff(d1, d2) {
		d1 = new Date(d1.replace(/-/g, '/'));
		d2 = new Date(d2.replace(/-/g, '/'));
		var obj = {},
			M1 = d1.getMonth(),
			D1 = d1.getDate(),
			M2 = d2.getMonth(),
			D2 = d2.getDate();
		obj.Y = d2.getFullYear() - d1.getFullYear() + (M1 * 100 + D1 > M2 * 100 + D2 ? -1 : 0);
		obj.M = obj.Y * 12 + M2 - M1 + (D1 > D2 ? -1 : 0);
		obj.s = Math.floor((d2 - d1) / 1000); //差几秒
		obj.m = Math.floor(obj.s / 60); //差几分钟
		obj.h = Math.floor(obj.m / 60); //差几小时
		obj.D = Math.floor(obj.h / 24); //差几天  

		return obj.M;
	}


	// 与当前时间相差

	static dateDiff1(dateString) {

		let regEx = new RegExp("\\-","gi");
        let validDateStr= dateString.replace(regEx,"/");
        let milliseconds = Date.parse(validDateStr);
        var date = new Date(milliseconds);
		let y = date.getFullYear();
		let m = date.getMonth() + 1;
		let d = date.getDate();
		d = d < 10 ? ('0' + d) : d;

		let timestamp = new Date().getTime();

		var time = '';

		if (timestamp > milliseconds) {

			var day = parseInt((timestamp - milliseconds) / (24 * 60 * 60 * 1000));

			if (day > 0) {

				if (day == 1) {

					return 'Yesterday'

				}else {
					return d + ' ' +  DateUtil.getENfromMoth(m);
				}	
			}else {

				var hour = parseInt((timestamp - milliseconds) / ( 60 * 60 * 1000));

				if (hour > 0) {

					return hour + 'h ago';

				}


				var min = parseInt((timestamp - milliseconds) / (60 * 1000));


				if (min > 0) {

					return min + 'm ago';

				}
			}
		}
			return '';
		}







	// 通过时间（18：00）显示 6：00 PM
	static getShowHMTime(time){


		if (!time) {

			return '';
		}



		var arr_str = time.split(':');

		var hour = parseInt(arr_str[0]);
		var minute = arr_str[1];

		if (hour >= 12) {

			return ((hour-12) == 0 ? '12' : (hour-12)) + ':' + minute + 'PM';

		}else {

			return ( hour == 0 ? '12' : hour ) + ':' + minute + 'AM';

		}

	}


	// 通过时间（2021-11-18 12:00:00）显示 12：00 PM
	static getShowHMTime2(dateString){


		let regEx = new RegExp("\\-","gi");
        let validDateStr=dateString.replace(regEx,"/");
        let milliseconds=Date.parse(validDateStr);
        let date = new Date(milliseconds);

		let hour = date.getHours();
		let minute = date.getMinutes();

		if (hour >= 12) {

			return ((hour-12) == 0 ? '12' : (hour-12)) + ':' + (minute >= 10 ? minute : '0' + minute) + 'PM';

		}else {

			return ( hour == 0 ? '12' : hour ) + ':' + (minute >= 10 ? minute : '0' + minute) + 'AM';

		}

	}




}