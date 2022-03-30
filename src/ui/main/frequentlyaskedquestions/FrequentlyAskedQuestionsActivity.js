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

import ProgressBar from '../../../widget/ProgressBar';

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



export default class FrequentlyAskedQuestionsActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       all_subjects:[],
       seleted_type:0,
       all_helps_content:[],
       seleted_help: -1, 
       submit_emaile:undefined,
       submit_message:undefined,
       submit_subject:undefined,
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


    this.getAllSubjects();

  }

  getAllSubjects(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getAllSubjects id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '</n0:getAllSubjects></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('help-manager','getAllSubjectsResponse',data, function(json) {

        if (json && json.success == 1) {
            // 当天有
             temporary.setState({
                all_subjects:json.data,
             }); 

             if (json.data && json.data.length > 0) {

                temporary.getAllHelpsContent(json.data[0].id);

             }


        }

    });      

  }


  clickSubmit(){

         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Fill in the Enquiry Form</Text>


                          <Text style = {[styles.text_popup_content]}>Enquiries will be submitted via Email</Text>



                          <Text style ={styles.text_popup_item_title}>Name</Text>

                          <Text style = {styles.text_popup_item_content}>{this.state.userBean ? this.state.userBean.first_name + ' ' + this.state.userBean.last_name : ''}</Text>

                          <View  style = {[styles.view_line,{marginTop:8}]}/>


                           <View style = {styles.view_iparinput}>
                              <IparInput 
                                  valueText = {this.state.submit_emaile}
                                  placeholderText={'Enter Email'}
                                  onBlur={() => {
                                      this.setState({
                                        keyboard:false,
                                      })
                                  }}
                                  onFocus={() => {
                                      this.setState({
                                        keyboard:true,
                                      })
                                  }}
                                  onChangeText={(text) => {
                                       
                                    this.setState({submit_emaile:text})
                                  }}/>

                          </View>



                          <TouchableOpacity
                               activeOpacity = {0.8}
                               onPress={this.clickSubmitSelectSubject.bind(this)}>

                              <View style = {[styles.view_item_head,{paddingTop:16,paddingBottom:16}]}>


                                  <Text style = {[styles.text_popup_item_content,{flex:1,color:this.state.submit_subject ? '#333333' : '#828282'}]}>{this.state.submit_subject ? this.state.submit_subject.subject : 'Select subject'}</Text>

                                  
                                   <Image style = {{width:12,height:8,marginTop:8,marginRight:16}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../../images/dawn_1231.png')}/>  
                
                                 
                              </View>


                          </TouchableOpacity>     

                          
                          <View  style = {[styles.view_line,{marginTop:8}]}/>


                           <View style = {styles.view_iparinput}>
                              <IparInput 
                                  valueText = {this.state.submit_message}
                                  placeholderText={'Message'}
                                  onBlur={() => {
                                      this.setState({
                                        keyboard:false,
                                      })
                                  }}
                                  onFocus={() => {
                                      this.setState({
                                        keyboard:true,
                                      })
                                  }}
                                  onChangeText={(text) => {
                                       
                                    this.setState({submit_message:text})
                                  }}/>

                          </View>
                          
                          




                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={() =>this.hidePopup()}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Back</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickSubmitPopConfirm.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Submit</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>


                          <View style = {{width:'100%',height:this.state.keyboard ? 280 : 0,}}/> 

                          
                        </View>
                    )
                },
            ()=>this.hidePopup(),
            CoverLayer.popupMode.bottom);

  }

  hidePopup(){
    this.coverLayer.hide();
    this.setState({
      keyboard:false,
    });
  }



    clickSubmitSelectSubject(){




    if (!this.state.all_subjects || this.state.all_subjects.length == 0) {

      return;
    }

   this.hidePopup();

    // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
        ()=> {
            return (
                <View style={styles.view_popup_bg}>


                  <Text style = {styles.text_popup_title}>Select Subject</Text>

                  <FlatList
                      style = {styles.flat_popup}
                      ref = {(flatList) => this._flatList = flatList}
                      renderItem = {this._subjects_renderItem}
                      onEndReachedThreshold={0}
                      keyExtractor={(item, index) => index.toString()}
                      data={this.state.all_subjects}/>

                 


                </View>
            )
        },
    ()=>this.hidePopup(),
    CoverLayer.popupMode.bottom);

  }


   _subjects_renderItem = (item) => {


      return (

        <TouchableOpacity
          style = {{width:'100%'}}
          activeOpacity = {0.8}
          onPress = {this.selectedSubjects.bind(this,item)}>

          <Text style = {[styles.text_popup_content,{textAlign:'left',color:'#333333'}]}>{item.item.subject}</Text>


          <View style = {[styles.view_item_line,{marginTop:11}]}/>


        </TouchableOpacity>  

      );

  }

  selectedSubjects(item){

    this.setState({
      submit_subject:item.item,
    });
    this.hidePopup();
    this.clickSubmit();
  }




  clickSubmitPopConfirm(){


    if (!this.state.submit_emaile || !this.state.submit_message || !this.state.submit_subject) {
      
      toastShort('Please fill in the full information！');
      return;
    }

     this.hidePopup();

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:saveClientEnquiry id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
     '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
     '<item><key i:type="d:string">client_submit_email</key><value i:type="d:string">'+ this.state.submit_emaile +'</value></item>'+
     '<item><key i:type="d:string">qa_content</key><value i:type="d:string">'+ this.state.submit_message +'</value></item>'+
     '<item><key i:type="d:string">subject_id</key><value i:type="d:string">'+ this.state.submit_subject.id +'</value></item>'+
     '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
     '</data></n0:saveClientEnquiry></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('help-manager','saveClientEnquiryResponse',data, function(json) {

        if (json && json.success == 1) {

          // temporary.setState({
          //   submit_emaile:undefined,
          //   submit_message:undefined,
          //   submit_subject:undefined,
          // });



          temporary.getTSystemConfig();


        }else {
          Loading.hidden();
          toastShort('Your enquiry has failed to submit!');

        }
    });      
  }


  getTSystemConfig(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getTSystemConfig id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<columns i:type="d:string">' + 'receive_specific_email' + '</columns>'+
    '</n0:getTSystemConfig></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('system-config','getTSystemConfigResponse',data, function(json) {

        if (json && json.success == 1) {

          temporary.sendSmsForEmail(json.data.receive_specific_email);

        }else {
          Loading.hidden();
          toastShort('Your enquiry has failed to submit!');

        }
    });      

  }


  sendSmsForEmail(receive_specific_email){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
    '<item><key i:type="d:string">email</key><value i:type="d:string">'+ receive_specific_email +'</value></item>'+
    '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.submit_emaile +'</value></item>'+
    '<item><key i:type="d:string">message</key><value i:type="d:string">'+ this.state.submit_message +'</value></item>'+
    '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow] Submit an enquiry</value></item>'+
    '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id + '</value></item>'+
    '</params></n0:sendSmsForEmail></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {

          temporary.setState({
            submit_emaile:undefined,
            submit_message:undefined,
            submit_subject:undefined,
          });

          toastShort('Your enquiry is submitted!');

        }else {

          toastShort('Your enquiry has failed to submit!');

        }
    });      

  }



  _allSubjectsView(){


    var items = [];

    if (this.state.all_subjects) {


      for (var i = 0; i < this.state.all_subjects.length; i++) {
        var subject = this.state.all_subjects[i];


        items.push(


         <TouchableOpacity 
            onPress={this.clickType.bind(this,i,subject)}
            activeOpacity = {0.8 }>

             <View style = {[styles.view_type_item,{backgroundColor:this.state.seleted_type == i ? '#C44729' : '#F2F2F2'}]}>


                <Text style = {this.state.seleted_type == i ? styles.text_type : styles.text_type_unselected}>{subject.subject}</Text>

            </View>

         </TouchableOpacity>   



        );

      }


    }


    return items;


  }


  clickType(type,subject){

    this.setState({
      seleted_type:type,
      seleted_help:-1
    });

    this.getAllHelpsContent(subject.id);

  }


  getAllHelpsContent(subject_id){


     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:getAllHelpsContent id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<companyId i:type="d:string">97</companyId>'+
     '<limit i:type="d:string">0</limit>'+
     '<subjectId i:type="d:string">'+ (subject_id == '-1' ? '0' : subject_id) +'</subjectId>'+
     '<cctOrMp i:type="d:string">'+ (subject_id == '-1' ? '2' : '0') +'</cctOrMp>'+
     '</n0:getAllHelpsContent></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('help-manager','getAllHelpsContentResponse',data, function(json) {

        if (json && json.success == 1) {
            // 当天有
             temporary.setState({
                all_helps_content:json.data,
             }); 

        }

    });      


  }





   _renderItem = (item) => {

    return (

      <TouchableOpacity 
            onPress={this.clickHelpItem.bind(this,item)}
            activeOpacity = {0.8 }>

        <View style = {styles.view_help_item}>

          <Text style = {styles.text_help_item_title}>{item.item.title}</Text>

          {this._helpItemContent(item)}


        </View>

      </TouchableOpacity>      

    );

   }


   _helpItemContent(item){



    if (item.index == this.state.seleted_help) {

      return (<Text style = {styles.text_help_item_content}>{item.item.content}</Text>);

    }else {

      return (<View/>);

    }



   }




   clickHelpItem(item){


    if (this.state.seleted_help == item.index) {

      this.setState({seleted_help:-1});

    }else {

      this.setState({seleted_help:item.index});

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

              <View style = {styles.bg}>

                  <Text style = {styles.text_title}>How can we help you?</Text>


                  <View style = {styles.view_search}>


                      <TextInput
                        style={styles.textInput}
                        placeholder="Type Keywords"/>


                  </View>


                <View style = {{width:'100%',height:50,marginTop:16}}>

                  <ScrollView
                      showsHorizontalScrollIndicator = {false}
                      horizontal={true}
                      contentOffset={{x: 0, y: 0}}>


                      {this._allSubjectsView()}

                    </ScrollView>  

                </View>
                
                


                <FlatList
                  ref = {(flatList) => this._flatList = flatList}
                  renderItem = {this._renderItem}
                  onEndReachedThreshold={0}
                  keyExtractor={(item, index) => index.toString()}
                  data={this.state.all_helps_content}/>





              </View> 



              <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout]}  
                          activeOpacity = {0.8}
                          onPress={this.clickSubmit.bind(this)}>


                      <Text style = {styles.next_text}>Submit an enquiry</Text>

                    </TouchableOpacity>


                </View>
   


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
    flex:1,
    backgroundColor:'#FFFFFF',
     padding:24,
  },
  next_layout:{
    width:'100%',
    height:44,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor:'#145A7C'
  },
  next_text :{
    fontSize: 14,
    color: '#FFFFFF',
    fontWeight: 'bold',
  },
  next_view:{
    paddingTop:16,
    width:'100%',
    backgroundColor:'#FFFFFF'
  },
  text_popup_item_title:{
    marginTop:32,
    width:'100%',
    fontSize:13,
    fontWeight: 'bold',
    color: '#333333',
  },
  text_title:{
    width:'100%',
    fontSize:24,
    fontWeight: 'bold',
    color: '#145A7C',
  },
  view_search:{
    marginTop:10,
    paddingTop:8,
    paddingLeft:16,
    paddingRight:16,
    paddingBottom:8,
    borderRadius: 50,
    height:40,
    borderWidth:0.5,
    borderColor:'#CCC'
  },
  textInput:{
    flex:1,
  },
  view_type_item:{
    marginLeft:4,
    marginRight:4,
    paddingLeft:12,
    paddingRight:12,
    paddingTop:8,
    paddingBottom:8,
    backgroundColor:'#145A7C',
    borderRadius:50,
  },
  text_type:{
    color:'#FFFFFF',
    fontSize:14,
    fontWeight:'bold',
  },
  text_type_unselected:{
     color:'#333333',
    fontSize:14,
  },
  view_help_item:{
    marginBottom:10,
    padding:16,
    borderRadius: 16,
    borderWidth:0.5,
    borderColor:'#CCC'
  },
  text_help_item_title:{
    color:'#333333',
    fontSize:18,
    fontWeight:'bold',
  },
  text_help_item_content:{
    marginTop:16,
    color:'#333333',
    fontSize:16,
  },
  view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
  xpop_cancel_confim:{
    marginTop:32,
    marginBottom:50,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom:74,
  },
  xpop_item:{
    borderRadius: 50,
    height:44,
   
    justifyContent: 'center',
    alignItems: 'center',
  },
  xpop_text: {
    fontSize:14,
    textAlign :'center',
    fontWeight: 'bold',
  },
  xpop_touch:{
     width:'48%',

  },
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
  text_popup_content : {
    marginTop:16,
    width:'100%',
    color:'#828282',
    fontSize:14,
    textAlign :'center',
  },
  text_popup_item_title:{
    marginTop:32,
    width:'100%',
    fontSize:13,
    fontWeight: 'bold',
    color: '#333333',
  },
  text_popup_item_content:{
    width:'100%',
    fontSize: 16,
    color: '#333333',
  },
  view_iparinput:{
    width:'100%',
  },
  view_item_line:{
    backgroundColor: "#E0E0E0",
    width: '100%',
    height: 1
  },
  flat_popup:{
    width:'100%',
  },
  view_item_head:{
    width:'100%',
    flexDirection: 'row',
  },
  view_line:{
    marginTop:16,
    width:'100%',
    height:1,
    backgroundColor:'#e0e0e0'
  },
});
