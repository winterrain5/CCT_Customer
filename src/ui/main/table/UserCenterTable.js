import React, {
  Component
} from 'react';
import PropTypes from 'prop-types';
import {
  Text,
  View,
  Image,
  StatusBar,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  DeviceEventEmitter
} from 'react-native';

import DeviceStorage from '../../../uitl/DeviceStorage';


export default class UserCenterTable extends Component {


	constructor(props) {
	    super(props);
	    this.state = {
	       head_company_id:'97',
	       userBean:undefined,
	    }
  	}


  	UNSAFE_componentWillMount(){

	    DeviceStorage.get('head_company_id').then((ompany_id) => {

	      if (ompany_id) {
	        this.setState({
	            head_company_id: ompany_id,
	          });
	      }else {
	        this.setState({
	            head_company_id: '97',
	          });

	      }
	    });

      DeviceStorage.get('UserBean').then((user_bean) => {
        this.setState({
            userBean: user_bean,
        });
      });

	 
  	}


    //注册通知
  componentDidMount(){

      var temporary = this;
      this.emit =  DeviceEventEmitter.addListener('user_update',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

           if (params) {
              temporary.setState({
                userBean: JSON.parse(params,'utf-8'),
               });
           }  
           
       });

  }

  componentWillUnmount(){

    this.emit.remove();
  
  }


  	clickEditUser(){




  	}


    clickItem(type){



      DeviceEventEmitter.emit('clickUseCenterItem',type);

      // const { navigation } = this.props;
   
      // if (navigation) {
      //   navigation.navigate('TopUpMethodActivity');
      // }


    }





  render() {
      return(

      	 <View style = {styles.bg}>

      	 	 <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

      	 	 <SafeAreaView style = {styles.afearea} />


      	 	 <View style = {styles.view_name}>

      	 	 	<Text style = {styles.text_name}>Hi,{this.state.userBean ? (this.state.userBean.first_name + ' ' + this.state.userBean.last_name) : ''}</Text>



              <TouchableOpacity  
              		style = {styles.view_edit} 
                    activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Edit User')}>

		            <Image style = {styles.image_edit} 
		                resizeMode = 'contain' 
		                source={require('../../../../images/edit_bi.png')}/>    



              </TouchableOpacity>      

      	 	 </View>



	         <ScrollView style = {styles.scrollview}
	            contentOffset={{x: 0, y: 0}}>

	             <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Home')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Home</Text>
                    </View>
                 </TouchableOpacity>      


                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'CCT Wallet')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>CCT Wallet</Text>
                    </View>
                 </TouchableOpacity>      


                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Appointments')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Appointments</Text>
                    </View>
                 </TouchableOpacity>      




                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Services')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Services</Text>
                    </View>
                 </TouchableOpacity>      


                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Shop')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Shop</Text>
                    </View>
                 </TouchableOpacity>      



                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'My Orders')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>My Orders</Text>
                    </View>
                 </TouchableOpacity>      


{/* 
                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Symptom Checker')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Symptom Checker</Text>
                    </View>
                 </TouchableOpacity>       */}



                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Conditions We Treat')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Conditions We Treat</Text>
                    </View>
                 </TouchableOpacity>      



                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Blog')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Blog</Text>
                    </View>
                 </TouchableOpacity>    


                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Madam Partum')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Madam Partum</Text>
                    </View>
                 </TouchableOpacity>    



                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,"Bookmarks")}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Bookmarks</Text>
                    </View>
                 </TouchableOpacity>    




                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Refer a Friend')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Refer a Friend</Text>
                    </View>
                 </TouchableOpacity>    



                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Our Story')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Our Story</Text>
                    </View>
                 </TouchableOpacity>    


                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Contact Us')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Contact Us</Text>
                    </View>
                 </TouchableOpacity>    


                  <TouchableOpacity  
	             	activeOpacity = {0.8}
                    onPress={this.clickItem.bind(this,'Frequenty Asked Questions')}>
                    <View style = {styles.view_item}>
                    	<Text style = {styles.text_item_name}>Frequenty Asked Questions</Text>
                    </View>
                 </TouchableOpacity>      







	         </ScrollView>   






      	 </View>


      	);

  }





}
const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea:{
    flex:0,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  view_head:{
    padding:24,
    width: '100%',
    backgroundColor:'#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  view_name:{
  	padding:20,
  	width: '100%',
    flexDirection: 'row'
  },
  text_name:{
  	color:'#FFFFFF',
    fontSize: 24,
    fontWeight: 'bold',
  },
  view_edit: {
  	marginLeft:18
  },
  image_edit:{
  	width:32,
  	height:32,
  },
  scrollview:{
    flex:1,
  },
  view_item:{
  	width:'100%',
  	paddingTop:12,
  	paddingBottom:12,
  },
  text_item_name:{
  	paddingLeft:24,
  	color:'#FFFFFF',
    fontSize: 16,
  }
 
});
