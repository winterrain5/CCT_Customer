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
  FlatList,
} from 'react-native';


import Swiper from 'react-native-swiper';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import DeviceStorage from '../../../uitl/DeviceStorage';

import DateUtil from '../../../uitl/DateUtil';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import {Card} from 'react-native-shadow-cards';

import QueueView from '../../../widget/QueueView';

import Swipeout from 'react-native-swipeout';

import { toastShort } from '../../../uitl/ToastUtils';


import { Loading } from '../../../widget/Loading';

let {width, height} = Dimensions.get('window');


export default class NotificationScreen extends Component {

 constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       today_postion:-1,
       earlier_postion:-1,
       sectionID:undefined,
       rowID:undefined,
       user_categories:undefined,
       isRefreshing:false,
       now_delete_type:0, // 当前删除类型 0 ：普通  1 ： 批量删除
       now_delete_datas:[], //  当前将要删除的通知id 集合
       delete_updo_send:0, //删除读秒倒计时
    }
  }


   //注册通知
  componentDidMount(){


    var temporary = this;

    this.emit =  DeviceEventEmitter.addListener('UpNotification',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         temporary.getClientCategory(temporary.state.userBean);
     });

  }

  componentWillUnmount(){

    this.emit.remove();
    this.timer && clearInterval(this.timer); 

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


      this.getClientCategory(user_bean);

    });

   
  }


  getClientCategory(user_bean){


    //获取用户屏蔽的
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientCategory id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">' + user_bean.id + '</clientId>'+
    '</n0:getClientCategory></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('notifications','getClientCategoryResponse',data, function(json) {

        console.error(json.data.models);

        if (json && json.success == 1 && json.data ) {

            temporary.setState({
              user_categories:json.data.models,
            })
            // 获取
            temporary.getNotices(json.data.models);
           
        }else {
           
            // 先获取所以的类型
            temporary.getAllCategories();
           

        }

    });      

  }

  getAllCategories(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getAllCategories id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId></n0:getAllCategories></v:Body></v:Envelope>';

    var temporary = this;

    WebserviceUtil.getQueryDataResponse('notifications','getAllCategoriesResponse',data, function(json) {

        
        if (json && json.success == 1) {

            var  user_categories = []; 

           if (json.data && json.data.length > 0) {

              for (var i = 0; i < json.data.length; i++) {
                var categorie = {};

                categorie.category_id = json.data[i].id;
                categorie.client_id = temporary.state.userBean.id;
                categorie.id = json.data[i].id;
                user_categories.push(categorie);
              }
           }  
           temporary.setState({
              user_categories:user_categories,
            });
            // 获取
            temporary.getNotices(user_categories);
           
        }else {

          temporary.setState({
            isRefreshing:false,
          });

        }

    });   

  }


  getNotices(items){


    var filters = '';

    for (var i = 0; i < items.length; i++) {
      
      filters += ('<item><key i:type="d:string">'+ i +'</key><value i:type="d:string">'+ items[i].category_id +'</value></item>');

    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNotices id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<filters i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+ filters +'</filters>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId></n0:getNotices></v:Body></v:Envelope>';

    var temporary = this;

    WebserviceUtil.getQueryDataResponse('notifications','getNoticesResponse',data, function(json) {

        console.error(json);


        if (json && json.success == 1) {

           // 处理数据
           temporary.handleNoticesData(json.data)
           
        }

         temporary.setState({
            isRefreshing:false,
          });


    }); 


    }  



    handleNoticesData(data){


      var today_postion = -1;
      var earlier_postion = -1;


      for (var i = 0; i < data.length; i++) {

        var bean = data[i];
       
        if (DateUtil.formatDateTime1() == DateUtil.parserDateString(bean.send_date)) {

          //当天
          if (today_postion == -1) {
            today_postion = i;
          }
        }else {
          // 非当日
          if (earlier_postion == -1) {

            earlier_postion = i;
          }

        }
        
      }

      this.setState({
          today_postion : today_postion,
          earlier_postion : earlier_postion,
          notices:data,
      });


    }

  countDownview(){


    if (this.state.delete_updo_send > 0) {

      return (


        <View style = {styles.view_undo}>


          <Text style = {styles.text_undo}>{this.state.now_delete_datas.length} Deleted</Text>


             <TouchableOpacity 
                activeOpacity = {0.8}
                onPress = {this.clickUndo.bind(this)}>

                 <Text style = {[styles.text_undo,{fontWeight: 'bold'}]}>Undo</Text>                 

            </TouchableOpacity>    

        


        </View>


      );




    }else {

      return (<View />);

    }
  }


  clickUndo(){


    this.unDoNotices();


  }



  clickCategories(){


    if (this.state.now_delete_type == 0) {

      DeviceEventEmitter.emit('selectedCategories',this.state.user_categories ? JSON.stringify(this.state.user_categories) : undefined);

    }else {


      if (this.state.now_delete_datas && this.state.now_delete_datas.length > 0) {

          this.deleteItems(this.state.now_delete_datas);

      }


    }


    
    
  }

  clickOpenMenu(){

    if (this.state.now_delete_type == 0) {
        DeviceEventEmitter.emit('openMenu','ok');
    }else {

      this.setState({
        now_delete_type : 0 ,
        now_delete_datas:[],
      });

    }

  }

  _renderItem = (item) => {

    var component_view ;



    var swipeoutBtns;

    if(this.state.now_delete_type == 0){

        swipeoutBtns = [
          {
              text: 'Delete',//按钮显示文案
              backgroundColor: '#fff',
              key:'1',
              onPress: ()=>{

                  var deleteItems = [];
                  deleteItems.push(item.item.id);

                  this.setState({
                    now_delete_datas:deleteItems,
                  });
                  this.deleteItems(deleteItems);
              },
              component: [

              
                  <View style={styles.view_delete}>

                     <Image style = {styles.image_home} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/honmg_delete.png')}/> 

                
                   </View>

              
              ],
          }
      ];

    } 
      return (

        <View 
        onLongPress = {this.longClickItem.bind(this,item)}
        style = {styles.view_item}>
           

           {this.noticesTitle(item)}

              <Swipeout 
                style = {styles.swipeout} 
                right={swipeoutBtns} 
                close={!(this.state.sectionID === item.item.id && this.state.rowID === item.index)}
                rowID={item.index}
                sectionID={item.item.id}
                onOpen={(sectionID, rowID) => {
                    this.setState({
                        sectionID:sectionID,
                        rowID:rowID,
                    });
                }}
                >
                 
                  <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 32,margin:8,height:100}} >

                    <TouchableOpacity 
                      activeOpacity = {0.8}
                      onPress = {this.clickItem.bind(this,item)}
                      onLongPress={this.longClickItem.bind(this,item)}>

                       <View style = {{width:'100%',borderWidth:2,borderColor:(this.state.now_delete_type == 1 && this.state.now_delete_datas.indexOf(item.item.id) != -1 ? '#C44729' : '#FFFFFF'),padding:16,borderRadius:16}}>


                            <View style = {[styles.view_item_title]}>

                              <Text style = {[styles.text_notification,{color:DateUtil.formatDateTime1() == DateUtil.parserDateString(item.item.send_date) ? '#145A7C' : "#88145A7C"}]} numberOfLines={1} >{item.item.title}</Text>


                              <Text style = {[styles.text_time,{color:DateUtil.formatDateTime1() == DateUtil.parserDateString(item.item.send_date) ? '#333333' : "#88333333"}]}  numberOfLines={1} >{DateUtil.dateDiff1(item.item.send_date)}</Text>


                            </View>


                            <Text style = {[styles.text_content,{color:DateUtil.formatDateTime1() == DateUtil.parserDateString(item.item.send_date) ? '#333333' : "#88333333"}]} numberOfLines={2} >{item.item.content}</Text>


                      </View>   

                   </TouchableOpacity>        


                  </Card>

              
            </Swipeout>

        </View>
      );

  }


  noticesTitle(item){

    if (item.index == this.state.today_postion) {

      return (<Text style = {styles.text_item_title}>Today</Text>);

    }else if (item.index == this.state.earlier_postion) {

      return (<Text style = {styles.text_item_title}>Earlier</Text>);

    }else {

      return (<View />);
    }

  }


  longClickItem(item){

    if (this.state.now_delete_type == 0) {

        var now_delete_datas = this.state.now_delete_datas ;
         now_delete_datas.push(item.item.id);

        this.setState({
          now_delete_type:1,
          now_delete_datas:now_delete_datas,
        });
    }
  }


  clickItem(item){

    if (this.state.now_delete_type == 1) {

      var now_delete_datas = this.state.now_delete_datas ;
      var index =  this.state.now_delete_datas.indexOf(item.item.id);


      if (index == -1) {

        now_delete_datas.push(item.item.id);

      }else {

        now_delete_datas.splice(index,1); 
      }


      this.setState({
        now_delete_datas:now_delete_datas,
      });


    }

  }

  deleteItems(items){


    var items_data = '';


    for (var i = 0; i < items.length; i++) {
        
        items_data += ('<item><key i:type="d:string">'+ i +'</key><value i:type="d:string">'+ items[i] +'</value></item>')  

    }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:deleteNotices id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<ids i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    items_data +
    '</ids></n0:deleteNotices></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();


    WebserviceUtil.getQueryDataResponse('notifications','deleteNoticesResponse',data, function(json) {

         Loading.hidden();
        if (json && json.success == 1) {

            toastShort('Success Deleted');
            temporary.setState({
              delete_updo_send:5
            });
            temporary.setSecondInterval();
            temporary.getNotices(temporary.state.user_categories);
           
        }else {
          toastShort('Deleted Failed');

        }

    }); 

  }

  setSecondInterval(){

    this.timer && clearInterval(this.timer); 

    this.timer = setInterval(() => {
      
        if (this.state.second == 0) {

            this.setState({
              now_delete_datas:[],
            });

           this.timer && clearInterval(this.timer); 
        }else {

            var new_second = this.state.delete_updo_send - 1;

            this.setState({
               delete_updo_send : new_second, 
            });

        }


    }, 1000);

  }




  unDoNotices(){

    var items = '';

    for (var i = 0; i < this.state.now_delete_datas.length; i++) {
       this.state.now_delete_datas[i]

       items += ('<item><key i:type="d:string">'+ i + '</key><value i:type="d:string">'+  this.state.now_delete_datas[i] + '</value></item>');
    }

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:unDoNotices id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<ids i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
     items + 
     '</ids></n0:unDoNotices></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();

    WebserviceUtil.getQueryDataResponse('notifications','unDoNoticesResponse',data, function(json) {

         Loading.hidden();
        if (json && json.success == 1) {

            toastShort('Success Undo')
            temporary.getNotices(temporary.state.user_categories);
           
        }else {
          toastShort('Undo Failed');

        }

    }); 


    
  }


  noDataView(){

    if (this.state.notices && this.state.notices.length > 0) {

       return (<View />);

    }else {

      return ( 
        <View style = {styles.view_no_data}>

             <Text style = {styles.text_no_data}>You have no notifications</Text>

        </View> 
      );
     
    }


  }


  refreshing(){


    this.setState({
      isRefreshing:true,
    });


    this.getClientCategory(this.state.userBean);


  }



  render() {
      return(
          <View style = {styles.bg}>

            <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


            <SafeAreaView style = {styles.afearea} />


            <View style = {styles.view_content}>


              <View style = {styles.view_head}>

               <TouchableOpacity 
                  activeOpacity = {0.8}
                  onPress={this.clickOpenMenu.bind(this)}>


                  {this.state.now_delete_type == 0 ? 

                    <Image style = {styles.image_home} 
                      resizeMode = 'contain' 
                      source={require('../../../../images/home_user.png')}/> 

                   :

                   <View style = {styles.view_delete_left}>

                      <Image
                        style={{width:8,height:12}}
                        source={require('../../../../images/left_0909.png')}
                        resizeMode = 'contain' />


                   </View>
                   
                 }     

                </TouchableOpacity> 

                <Text style = {styles.text_title}>Notification</Text>     



                 <TouchableOpacity 
                    activeOpacity = {0.8 }
                    onPress={this.clickCategories.bind(this)}>


                    {this.state.now_delete_type == 0 ? 

                       <Image style = {styles.image_home} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/vector.png')}/>

                      :   

                      <Image style = {styles.image_home} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/delete0609.png')}/>



                    }

                   

                 </TouchableOpacity>  
 
              </View> 


              {this.countDownview()}


              <View style = {styles.bg}>


             <FlatList
                ref = {(flatList) => this._flatList = flatList}
                onRefresh={this.refreshing.bind(this)}
                refreshing={this.state.isRefreshing}
                renderItem = {this._renderItem}
                onEndReachedThreshold={0}
                keyExtractor={(item, index) => index.toString()}
                data={this.state.notices}/>


            </View>



            {this.noDataView()}



          </View>


        
          </View>    
      );
  }

}

const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF',
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
    padding:19,
    width: '100%',
    backgroundColor:'#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  image_home :{
    width:18,
    height:18
  },
  text_title :{
    color:'#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
   scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_item:{
    width:'100%',
  },
  text_item_title:{
    marginTop:8,
    marginBottom:8,
    width:'100%',
    marginLeft:16,
    color:'#000',
    fontSize:12,
  },
  view_delete :{
    height:100,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image_delete:{
    width:20,
    height:20,
  },
  swipeout:{
    backgroundColor:'#fff',
  },
  view_item_title:{
    width: '100%',
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_notification:{
    flex:1,
    color:"#145A7C",
    fontSize: 16,
    fontWeight: 'bold',
  },
  text_time:{
    color:"#333",
    fontSize: 12,
    fontWeight: 'bold',
  },
  text_content:{
    marginTop:8,
    color:'#333',
    fontSize:14,
  },
  view_no_data:{
    position:'absolute',
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_content:{
    flex:1,
    backgroundColor:'#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_no_data: {
    color:"#BDBDBD",
    fontSize: 16,
    fontWeight: 'bold',
  },
  rightView: {
    width: 50,
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_delete_left:{
    width:18,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_undo:{
    paddingLeft:16,
    paddingRight:16,
    width:'100%',
    height:44,
    backgroundColor:'#C44729',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_undo:{
    color:"#FFFFFF",
    fontSize: 16,
  }
 
});




