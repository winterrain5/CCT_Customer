import {
	Component
} from 'react';


export default class StringUtils extends Component {





	// 是否是新加坡IC 号
	static isNRIC(card_number) {



		if (!card_number) {

			return false;
		}




		if (card_number.length != 9) {
			return false;
		}




		// 首字母 是否是SFTG
		if (card_number.substr(0, 1) == 'S' || card_number.substr(0,1) == 'F' || card_number.substr(0,1) == 'T' || card_number.substr(0,1) == 'G') {




			var Su = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

			//尾字母
			if (!Su.indexOf(card_number.substr(8,9))) {

				return false;
			}



			// 中间数字
			var str_number = '0123456789';		
			
			for (var i = 1; i < 8; i++) {
				
				if (str_number.indexOf(card_number.substr(i,1)) == -1) {

					return false;
				}

			}


			// 获取总数
			var number_total = 0;
			
			var number_che = [2,7,6,5,4,3,2];


			for (var i = 1; i < 8; i++) {

				number_total += (parseInt(card_number.substr(i,1)) * number_che[i-1]);	

			}
			




			if (card_number.substr(0, 1) == 'T' || card_number.substr(0,1) == 'G' ) {

				number_total += 4 ;
			}


			var yu = number_total % 11 ;





			if (card_number.substr(0, 1) == 'F' || card_number.substr(0,1) == 'G' ) {


				var end_zimu = ['X','W','U','T','R','Q','P','N','M','L','K'];


		
				if (card_number.substr(8,1) != end_zimu[yu]) {
					return false;
				}


			}else {

				var end_zimu = ['J','Z','I','H','G','F','E','D','C','B','A'];




				if (card_number.substr(8,1) != end_zimu[yu]) {
					return false;
				}




			}

		}else {

			return false;
		}


		return true;

		
	}



	// 是否是邮箱

	static isEmail(email){



		var emreg =/([-a-zA-Z_0-9.]+)@([-a-zA-Z0-9_]+(\.[a-zA-Z]+)+)/;


		if(emreg.test(email)){
			return true;
		}else {
			return false ;
		}
	}


	// 是否是密码
	static isPassword(password){


		if (!password || password.length < 6) {
			return false;
		}


		// 是否包含数字
		var number_reg=/\d/;

		if (!number_reg.test(password)) {

			return false;
		}


		// 是否包含大写字母

    	 var capital_reg = password.match(/^.*[A-Z]+.*$/);
    
    	 if (capital_reg == null) {

			return false;

    	 }


    	 // 是否包含小写字母
		var lowercase_reg = password.match(/^.*[a-z]+.*$/);
		if (lowercase_reg == null) {
			return false;
		}


		return true;


	}

	// 是否是新加坡邮政编码
	static isPostCode(post_code){


		if (!post_code) {

			return false;
		}


		if (post_code.length != 6) {
			return false;
		}


	// 中间数字
		var str_number = '0123456789';		
			
		for (var i = 0; i < 6; i++) {
				
			if (str_number.indexOf(post_code.substr(i,1)) == -1) {

				return false;
			}
		}


		var number = parseInt(post_code.substr(0,2));


		if (number < 0 || number > 82) {
			return false;
		}

		return true;

	}


	//隐藏NRIC号
	static hideNRIC(nric){


		if (!nric) {
			return '';
		}


		var showIRIC = '';


		for (var i = 0; i < nric.length; i++) {


			if (i < (nric.length - 4)) {

				showIRIC += '*';

			}else {

				showIRIC += nric.substr(i,1);

			}

		}

		return showIRIC;


	}


	// 金额保留2位小数

	static toDecimal(amount){

		var new_amount = 0.00;

		if (amount) {

			new_amount = Number(amount.toString().match(/^\d+(?:\.\d{0,2})?/));

		}


		var s_x = new_amount.toString(); //将数字转换为字符串
              
        var pos_decimal = s_x.indexOf('.'); //小数点的索引值
              

		  // 当整数时，pos_decimal=-1 自动补0  
		  if (pos_decimal < 0) {  
		      pos_decimal = s_x.length;  
		      s_x += '.';  
		  }

		 // 当数字的长度< 小数点索引+2时，补0  
		 while (s_x.length <= pos_decimal + 2) {  
		      s_x += '0';  
		 }  
		 return s_x;  

	}

	//总评分保留 一位小数
	static toDecimal1(amount){

		var new_amount = 0.0;

		if (amount) {

			new_amount = Number(amount.toString().match(/^\d+(?:\.\d{0,1})?/));

		}

		var s_x = new_amount.toString(); //将数字转换为字符串
              
        var pos_decimal = s_x.indexOf('.'); //小数点的索引值
              

		  // 当整数时，pos_decimal=-1 自动补0  
		  if (pos_decimal < 0) {  
		      pos_decimal = s_x.length;  
		      s_x += '.';  
		  }

		 // 当数字的长度< 小数点索引+2时，补0  
		 while (s_x.length <= pos_decimal + 1) {  
		      s_x += '0';  
		 }  
		 return s_x;  

	}




	// YYYY-MM-DD => MM/YYYY
	static showDateYMDtoMY(date){

		var dates = date.split('-');

		if (!dates || dates.length != 3) {
			return '';
		}


		return dates[1] + '/' + dates[0];



	}

	// 判断是否是数字
	static isNumber(amount){

		var regPos = /^\d+(\.\d+)?$/; //非负浮点数

   		var regNeg = /^(-(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*)))$/; //负浮点数

    	if(regPos.test(amount) || regNeg.test(amount)) {

	        return true;

	    } else {

	        return false;
	        
	    }

	}

	static uuid(len,radix){

		var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
	    var uuid = [],
	        i;
	    radix = radix || chars.length;

	    if (len) {
	        // Compact form
	        for (i = 0; i < len; i++) uuid[i] = chars[0 | Math.random() * radix];
	    } else {
	        // rfc4122, version 4 form
	        var r;

	        // rfc4122 requires these characters
	        uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
	        uuid[14] = '4';

	        // Fill in random data.  At i==19 set the high bits of clock sequence as
	        // per rfc4122, sec. 4.1.5
	        for (i = 0; i < 36; i++) {
	            if (!uuid[i]) {
	                r = 0 | Math.random() * 16;
	                uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
	            }
	        }
	    }

	    return uuid.join('');

	}




}