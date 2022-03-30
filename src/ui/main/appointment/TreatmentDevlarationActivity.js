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
  Dimensions
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


import {CommonActions,useNavigation} from '@react-navigation/native';


let {width, height} = Dimensions.get('window');


export default class TreatmentDevlarationActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       service:undefined,
       userBean:undefined,
       gender:1,
       user_data:[],
       xingguang_data:[],
       data:[],
       remarks:undefined,
       isOneChecked:false,
       well_treatment:0,   // 问卷类型  0 ：保健问卷    1 ：治疗问卷
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

  
    if (this.props.route.params) {

      this.setState({
        service:this.props.route.params.service,
        gender:this.props.route.params.gender,
        well_treatment:this.props.route.params.well_treatment,
      });
    }

    DeviceStorage.get('UserBean').then((user_bean) => {


      if (user_bean == undefined) {

        return;
      }


      this.setState({
          userBean: user_bean,
      });


      //获取已经填写的问卷
      this.getUserTAllItems();

    });

  }

  getUserTAllItems(){


    if (!this.state.userBean || !this.state.gender) {
      return;
    }


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTAllItems id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<gender i:type="d:string">'+ this.state.gender +'</gender>'+
    '<category i:type="d:string">'+ (this.state.well_treatment == 0 ? '1' : '3') + '</category>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:getTAllItems></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('questionnaire-survey','getTAllItemsResponse',data, function(json) {


      if (json && json.success == 1) {

        temporary.setState({
          user_data:json.data,
        })
      }

      // 获得新冠
      temporary.getXinGuanItem();

      
    });      

  }

getXinGuanItem(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTAllItems id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<gender i:type="d:string">'+ this.state.gender + '</gender>'+
    '<category i:type="d:string">2</category>'+
    '<clientId i:type="d:string">0</clientId>'+
    '</n0:getTAllItems></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('questionnaire-survey','getTAllItemsResponse',data, function(json) {


      if (json && json.success == 1) {

        temporary.setState({
          xingguang_data:json.data,
        })
      }

      // 获得所有
      temporary.getTAllItems();

      
    });      

}

getTAllItems(){

  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTAllItems id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<gender i:type="d:string">'+ this.state.gender +'</gender>'+
  '<category i:type="d:string">'+ (this.state.well_treatment == 0 ? '1' : '3') +'</category>'+
  '<clientId i:type="d:string">0</clientId>'+
  '</n0:getTAllItems></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('questionnaire-survey','getTAllItemsResponse',data, function(json) {

      Loading.hidden();
      if (json && json.success == 1) {

        temporary.setViewData(json.data);
        
      }
    });      
}


setViewData(allItem){



  var show_data = [];


  if (this.state.xingguang_data) {


    for (var i = 0; i < this.state.xingguang_data.length; i++) {
     
        var xingguang_item = this.state.xingguang_data[i];


        var hosty_item = undefined;


        if (this.state.user_data) {

          for (var j = 0; j < this.state.user_data.length; j++) {
           
              if (xingguang_item.id == this.state.user_data[j].id) {

                hosty_item = this.state.user_data[j];

              }

          }

        }

        if (hosty_item) {
          show_data.push(hosty_item);
        } else {
           show_data.push(xingguang_item);
        } 
    }

  }



   if (allItem) {


    for (var i = 0; i < allItem.length; i++) {
     
        var all_item = allItem[i];


        var hosty_item = undefined;


        if (this.state.user_data) {

          for (var j = 0; j < this.state.user_data.length; j++) {
           
              if (all_item.id == this.state.user_data[j].id) {

                hosty_item = this.state.user_data[j];

              }

          }

        }

        if (hosty_item) {
          show_data.push(hosty_item);
        } else {
           show_data.push(all_item);
        } 
    }


  }


  this.setState({
    data:show_data
  })




}


_enderItem = (item) => {


      return (

      <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >

        <View style = {styles.view_card_item}>

          <Text style = {styles.text_item_title}>{item.index >= 10 ? 'Question ' + (item.index + 1) : 'Question 0' + (item.index + 1)}</Text>

          <Text style = {styles.text_item_content}>{item.item.description_en}</Text>



          <View style = {styles.view_item_result}>




                <TouchableOpacity style = {styles.view_item_onclick}  
                    activeOpacity = {0.8 }
                    onPress={this.clickItemNo.bind(this,item)}>


                     <View style = {[styles.view_item_result_item,{backgroundColor:item.item.result == '1' ? '#F2F2F2' : '#FFFFFF'}]}>

                        <Text style = {[styles.text_item_result_item,{color:item.item.result == '1' ? '#C44729' : '#dbdbdb'}]}>No</Text>

                     </View>


                </TouchableOpacity>    



              <TouchableOpacity style = {styles.view_item_onclick}  
                    activeOpacity = {0.8 }
                    onPress={this.clickItemYes.bind(this,item)}>

                <View style = {[styles.view_item_result_item,{backgroundColor:item.item.result == '2' ? '#F2F2F2' : '#FFFFFF'}]}>

                  <Text style = {[styles.text_item_result_item,{color:item.item.result == '2' ? '#C44729' : '#dbdbdb'}]}>Yes</Text>

                 </View>

              </TouchableOpacity>    


               <TouchableOpacity style = {styles.view_item_onclick}  
                    activeOpacity = {0.8 }
                    onPress={this.clickItemUnsure.bind(this,item)}>


                    <View style = {[styles.view_item_result_item,{backgroundColor:(item.item.result == undefined || item.item.result == '3' ) ? '#F2F2F2' : '#FFFFFF'}]}>


                      <Text style = {[styles.text_item_result_item,{color:(item.item.result == undefined || item.item.result == '3' ) ? '#C44729' : '#dbdbdb'}]}>Unsure</Text>

                    </View>

              </TouchableOpacity>


           

              

          </View>


        

        </View>

      </Card>

      );

  }


  clickItemNo(item){


    var show_data = this.state.data;

    show_data[item.index].result = '1'


    this.setState({

      data:show_data,

    });


  }


  clickItemYes(item){


    var show_data = this.state.data;

    show_data[item.index].result = '2'

    this.setState({

      data:show_data,

    });

  }


  clickItemUnsure(item){


    var show_data = this.state.data;

    show_data[item.index].result = '3'

    this.setState({

      data:show_data,

    });
  }



  head = () => {


    return (

      <View style = {{width:'100%'}}>

          <Text style = {styles.text_title}>Complete the Health Declaration From</Text>

          <Text style = {styles.text_content}>It is impottant that you declare any health concerns before we treat your condition</Text>


      </View>

      );


  }




  footer = () => {

    var verify = '';
    var acknowledge = '';


    if (this.state.well_treatment == 0 ) {

        verify = 'I verify I have stated all my known medical conditions. I understand that I will be receiving massage therapy for stress reduction, muscle relief, or improving circulation and energy flow. I understand that the massage therapist does not diagnose illnesses. As such, she also does not prescribe medical treatment or medications. I also understand that she does not perform spinal manipulations. I am aware that this massage is not a substitute for medical examination or diagnosis, and that it is recommended that I see a physician for any ailment that I might have. I understand and agree that I am receiving massage therapy entirely at my own risk. In the event that I become injured either directly or indirectly as a result, in whole or in part, of the aforesaid message therapy. I HEREBY INDEMNIFY the therapist, her principles, and company from all claims and liability whatsoever.';
        acknowledge = 'I acknowledge that the above information given by me is compete and accurate to the best of my knowledge and that no fact that is likely to influence the safety of the treatment(s) that I have signup up for have been withheld.';
    }else {

        verify = 'I am willing to provide my practitioner with the information necessary for them to fully understand my medical history, presenting symptoms and the health goals I wish to achieve. I thereby consent to a thorough case history and Traditional Chinese Medicine diagnosis. I understand the methods of treatment may include but are not limited to: acupuncture, moxibustion, cupping, electrical stimulation, Tui Na (massage), and Chinese herbal medicine.I understand that it is my responsibility to inform the practitioner of all current medications, herbs and supplements that I take, as they may affect the treatment plan.I understand and agree that I am treatment and/or massage entirely at my own risk. In the event that I become injured either directly or indirectly as a result, in whole or in part, of the aforesaid. I HEREBY INDEMNIFY the Phyisican, therapist, her principles, and company from all claims and liability whatsoever.';
        acknowledge = 'I acknowledge that the above information given by me is compete and accurate to the best of my knowledge and that no fact that is likely to influence the safety of the treatment(s) that I have signup up for have been withheld.';

    }





    return (
      
      <View style = {styles.view_foot}>



         <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >


            <View style = {styles.view_card_item}>


              <Text style = {styles.text_item_content}>Remarks</Text>

              <TextInput
                placeholder = 'Let us know...'
                style = {{width:'100%',marginTop:24}}
                onChangeText={(text) => this.setState({remarks:text})}
                value={this.state.remarks}
                />

              <View style = {styles.view_line}/>


            </View>



         </Card>



        <Text style = {styles.text_read_title}>Please read and acknowledge</Text>


      
       <View style = {styles.view_notic}>

          <View style = {styles.view_checkbox}>
              <CheckBox 
                style={styles.checkbox} 
                rightText={''}
                rightTextStyle = {styles.text_foot_content}
                onClick={()=>{
                this.setState({
                    isOneChecked:!this.state.isOneChecked})
                }}
                isChecked={this.state.isOneChecked}
                checkedCheckBoxColor = "#C44729"
                uncheckedCheckBoxColor = "#C44729"/>   

          </View>

          <View style = {{width:'100%',flex:1}}>

             <Text style = {styles.text_checkbox_content}>{verify}</Text>
             <Text style = {styles.text_checkbox_content}>{acknowledge}</Text>


          </View>


      </View>




        <View style = {styles.next_view}>

            <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.isOneChecked) ? '#C44729':'#BDBDBD'}]}  
              activeOpacity = {(this.state.isOneChecked)  ? 0.8: 1}
              onPress={this.clickConfirm.bind(this)}>


            <Text style = {styles.next_text}>Confirm</Text>

          </TouchableOpacity>

        </View>



      </View>


    )};



    clickConfirm(){



      // 保存问卷
      this.savePatientResults();

    }


  savePatientResults(){

    var tcm_lines_data = '';


    for (var i = 0; i < this.state.data.length; i++) {
      
      tcm_lines_data += ('<item><key i:type="d:string">' + i + '</key><value i:type="n1:Map"><item><key i:type="d:string">result</key><value i:type="d:string">'+ (this.state.data[i].result == undefined ? '3' : this.state.data[i].result) +'</value></item><item><key i:type="d:string">questionnaire_id</key><value i:type="d:string">'+  this.state.data[i].id + '</value></item></value></item>');

    }


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:savePatientResults id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap"><item><key i:type="d:string">tcm_lines_data</key>'+
    '<value i:type="n1:Map">' + tcm_lines_data +
    '</value></item>'+
    '<item><key i:type="d:string">Summary_Data</key><value i:type="n1:Map">'+
    '<item><key i:type="d:string">registration_id</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">create_time</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
    '<item><key i:type="d:string">category</key><value i:type="d:string">'+ (this.state.well_treatment == 0 ? '1' : '3') +'</value></item>'+
    '<item><key i:type="d:string">remarks</key><value i:type="d:string">'+ this.state.remarks +'</value></item>'+
    '<item><key i:type="d:string">location_id</key><value i:type="d:string">'+ this.state.service.location_id +'</value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id+'</value></item>'+
    '</value></item></data></n0:savePatientResults></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('questionnaire-survey','savePatientResultsResponse',data, function(json) {

    
      if (json && json.success == 1) {

        // 修改服务状态
        temporary.changeTStatus();

      }else {
        Loading.hidden();
        toastShort('Request was aborted!')
      }
    });    

  }


  changeTStatus(){

    var create_queue_no = '0';

    if (this.state.service.wellness_treatment_type == '2' && this.state.service.wellness_or_treatment == '2') {
      create_queue_no = '1';
    }else {
      create_queue_no = '0';
    }

   

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:changeTStatus id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<timeId i:type="d:string">'+ this.state.service.id +'</timeId>'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">status</key><value i:type="d:string">4</value></item>'+
    '<item><key i:type="d:string">create_queue_no</key><value i:type="d:string">'+ create_queue_no + '</value></item></data>'+
    '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">' + this.state.userBean.user_id +'</value></item>'+
    '</logData></n0:changeTStatus></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('booking-order','changeTStatusResponse',data, function(json) {

       Loading.hidden();
      if (json && json.success == 1) {

        // 修改服务状态
        temporary.toMainActivity();


      }else {
        toastShort('Request was aborted!')
      }
    });    

  }


  toMainActivity(){

    const { navigation } = this.props;
    if (navigation) {
      // navigation.replace('MainActivity');
      navigation.dispatch(
        CommonActions.reset({
          index: 0,
          routes: [
            { name: 'MainActivity' },
          ],
       })
      );
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
                hideRightArrow = {false}/>


              <View style = {styles.view_content}>


    

                <FlatList
                  style = {styles.flat_popup}
                  ref = {(flatList) => this._flatList = flatList}
                  renderItem = {this._enderItem}
                  onEndReachedThreshold={0}
                  keyExtractor={(item, index) => index.toString()}
                  ListHeaderComponent = {this.head}
                  ListFooterComponent={this.footer}
                  data={this.state.data}/>


              </View>  


          </SafeAreaView>


          <SafeAreaView style = {styles.afearea_foot} />
          
          <CoverLayer ref={ref => this.coverLayer = ref}/>



        </View>

      );


   }

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
  text_title : {
    marginTop:8,
    color:'#145A7C',
    fontSize: 24,
    fontWeight: 'bold',
  },
  text_content: {
    marginTop:8,
    color:'#333333',
    fontSize:16,
  },
  flat_popup:{
    marginTop:24,
    width:'100%'
  },
  text_item_title:{
    fontSize:10,
    color:'#333',
    fontWeight:'bold',
  },
  view_card_item:{
    padding:16
  },
  text_item_content:{
    marginTop:5,
    color:'#333333',
    fontSize:16,
  },
  view_item_result:{
    width:'100%',
    height:45,
    marginTop:16,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_item_result_item:{
    width:'100%',
    height:'100%',
    flex:1,
    borderRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_item_result_item:{
    fontSize:16,
    fontWeight:'bold'
  },
  view_item_onclick:{
    width:'100%',
    height:'100%',
    flex:1,
  },
  view_foot:{
    width:'100%',
    paddingTop:16,
    paddingBottom:16,
  },
  text_hint : {
    color:'#333333',
    fontSize:16,
  },
  view_notic :{
      marginTop:32,
      flexDirection: 'row',
  },
  text_foot_content:{
    fontSize:14,
    color:'#333'
  },
  text_foot_title:{
    fontSize:14,
    color:'#C44729',
    fontWeight: 'bold',
  },
   view_checkbox:{
     marginRight:11,
  },
  text_checkbox_content:{
    flex:1,
    fontSize:14,
    color:'#333',
    lineHeight:20
  },
  next_layout:{
      marginTop:16,
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
  view_line: {
    marginTop:8,
    backgroundColor:'#828282',
    width:'100%',
    height:0.5,

  },
  text_read_title:{
    marginTop:16,
    fontSize: 14,
    color: '#000000',
    fontWeight: 'bold',

  } 
  
});




