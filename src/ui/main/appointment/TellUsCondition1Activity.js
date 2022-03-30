import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Text,
  View,
  ImageBackground,
  Image,
  TextInput,
  FlatList,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  Dimensions,
  NativeModules
} from 'react-native';

import TitleBar from '../../../widget/TitleBar';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';

let {width, height} = Dimensions.get('window');

export default class TellUsCondition1Activity extends Component {


   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       question_data:undefined,
       selected_ids_1:[],
    }
  }


   UNSAFE_componentWillMount(){

  
    DeviceStorage.get('head_company_id').then((company_id) => {


      if (company_id) {
        this.setState({
            head_company_id: company_id,
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


    this.getQuestions();

    
  }


  getQuestions(){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getQuestions id="o0" c:root="1" xmlns:n0="http://terra.systems/"><questionCategory i:type="d:string">1</questionCategory></n0:getQuestions></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('symptoms-check','getQuestionsResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data) {

            temporary.setState({
              question_data:json.data,
            })
          
        }     
    });


  }






 _renderItem = (item) => {


      return (

        <TouchableOpacity
          activeOpacity = {0.8}
          onPress = {this.clickItem.bind(this,item)}>


          <View style = {{marginTop:4,marginBottom:4}}>

            <View style = {[styles.view_item,{backgroundColor:this.isInArray(item.item.id) ? '#F2F2F2' : '#FFFFFF'}]}>

              <Text style = {[styles.text_item_title,{color:this.isInArray(item.item.id) ? '#C44729' : '#BDBDBD'}]}>{item.item.title}</Text>

            </View>

          </View>

        
        </TouchableOpacity>  

      );

  }


  // 判断数据是否在数组中
  isInArray(id){

    var isIn = false;

    for (var i = 0; i < this.state.selected_ids_1.length; i++) {
      
      if (this.state.selected_ids_1[i] == id) {

        isIn = true;

        break;
      }

    }

    return isIn;



  }

  clickItem(item){


     var new_ids = this.state.selected_ids_1;

    if (this.isInArray(item.item.id)) {

      
      for (var i = 0 ; i < new_ids.length; i++) {
        
        if (new_ids[i] == item.item.id) {

          new_ids.splice(i,1);

          break

        }

      }



    }else {
       new_ids.push(item.item.id);

    }

    this.setState({
      selected_ids_1:new_ids,
    })


  }


  clickNext(){

    

    if (this.state.selected_ids_1.length > 0) {
      if (this.props.isNative) {
        NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'TellUsCondition2Activity',property:{
          'selected_ids_1':this.state.selected_ids_1,
        }});
        return;
      }

      const { navigation } = this.props;

      if (navigation) {
        navigation.navigate('TellUsCondition2Activity',{
            'selected_ids_1':this.state.selected_ids_1,
          });
      }
     

    }

  }



  render() {

    const { navigation } = this.props;


    return(

       <View style = {styles.bg}>

         <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


        <SafeAreaView style = {styles.afearea} >

          <TitleBar
              title = {''} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>


          <View style = {styles.view_content}>


            <Text style = {styles.text_title}>Tell us about your condition</Text>


            <View style = {[styles.bg,{marginTop:32}]}>


               <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:16,margin:8}} >


                  <Text style = {styles.text_question_title}>Question 01</Text>

                  <Text style = {styles.text_question_content}>What symptoms are you experiencing?</Text>



                  <FlatList
                    style = {styles.flat_popup}
                    ref = {(flatList) => this._flatList = flatList}
                    renderItem = {this._renderItem}
                    onEndReachedThreshold={0}
                    keyExtractor={(item, index) => index.toString()}
                    data={this.state.question_data}/>



               </Card>





            </View>



            <View style = {styles.next_view}>

                <TouchableOpacity style = {[styles.next_layout,{backgroundColor: this.state.selected_ids_1.length > 0 ? '#C44729' : '#E0E0E0'}]}  
                    activeOpacity = {0.8 }
                    onPress={this.clickNext.bind(this)}>


                       <Text style = {styles.next_text}>Next</Text>

                </TouchableOpacity>

            </View>

          


          </View>    



        </SafeAreaView>



        <SafeAreaView style = {styles.afearea_foot} />
          




       </View>


      );

  };
}


const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
  },
   afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  view_content:{
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  text_title : {
    marginTop:8,
    color:'#145A7C',
    fontSize: 24,
    fontWeight: 'bold',
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
    next_layout:{
      width:'100%',
      height:44,
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center'
  },
  next_text :{
      fontSize: 14,
      color: '#FFFFFF',
      fontWeight: 'bold',
  },
  next_view:{
    marginTop:16
  },
  view_phone_wechat:{
    flex:1,
    flexDirection: 'row',
  },
  text_question_title:{
    color:'#333',
    fontSize: 13,
    fontWeight: 'bold',
  },
  text_question_content:{
    color:'#333',
    fontSize: 16,
  },
  flat_popup:{
    marginTop:24,
    width:'100%'
  },
  text_item_title:{
    fontSize: 16,
    fontWeight: 'bold',
  },
  view_item:{
    padding:12,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center'
  },
});




