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
} from 'react-native';

import WebserviceUtil from '../uitl/WebserviceUtil';

import DateUtil from '../uitl/DateUtil';





export default class QueueView extends Component {

	static propTypes = {
	  
	   service: PropTypes.object.isRequired,
	   location_id:PropTypes.string,  

  	}


  	constructor(props) {
        super(props);
        this.state = {
            wait_service_info:undefined,
          
        }
    }


    componentDidMount(){


    	this.getWaitServiceInfo();

    }



    getWaitServiceInfo(){


    	var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header />'+
    	'<v:Body><n0:getWaitServiceInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    	'<startTime i:type="d:string">'+ DateUtil.formatDateTime1() + '</startTime>'+
    	'<endTime i:type="d:string">'+ DateUtil.formatDateTime5(24*60*60*1000) +'</endTime>'+
    	'<wellnessTreatType i:type="d:string">2</wellnessTreatType>'+
    	'<locationId i:type="d:string">'+ (this.props.service ? this.props.service.location_id : this.props.location_id) +'</locationId></n0:getWaitServiceInfo></v:Body></v:Envelope>';
    	var temporary = this;
   		WebserviceUtil.getQueryDataResponse('booking-order','getWaitServiceInfoResponse',data, function(json) {

        
        if (json && json.success == 1  ) {

            // 当天有
             temporary.setState({
                wait_service_info:json.data,
             }); 

        }

    });      


    }





 	 render() { 


 	 	return(

 	 		<View style = {{flex:1}}>


              <View style = {{width:'100%',flexDirection: 'row'}}>

                <Text style = {styles.text_item_content2}>{this.state.wait_service_info ? this.state.wait_service_info.queue_count : '0'}</Text>

                <Text style = {[styles.text_item_content2,{fontWeight:'normal'}]}>currently in queue</Text>

              </View>


              <View style = {{width:'100%',flexDirection: 'row'}}>

                <Text style = {[styles.text_item_content2,{fontWeight:'normal'}]}>Estimated </Text>

                <Text style = {[styles.text_item_content2]}>{this.state.wait_service_info ? this.state.wait_service_info.duration_mins : '0'} mins </Text>

                <Text style = {[styles.text_item_content2,{fontWeight:'normal'}]}>waiting time</Text>

              </View>
                              
             </View>  
        	


 	 	);



 	 }



}






const styles = StyleSheet.create({

 text_item_content2:{
    marginLeft:6,
    color:'#333',
    fontSize:14,
    fontWeight:'bold',
  },
  header: {
    width: '100%',
    height: 50,
    backgroundColor: '#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },

  titleView: {
    height: '100%',
    justifyContent: 'center',
  },

  title: {
    fontSize: 16,
    color: '#FFFFFF',
     fontWeight: 'bold',
  },

  rightView: {
    width: 50,
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },

  rightText: {
    marginTop: 3,
    fontSize: 10,
    color: '#666666',
  },

  line: {
    width: '100%',
    height: 1,
    backgroundColor: '#e1e1e1'
  }
});