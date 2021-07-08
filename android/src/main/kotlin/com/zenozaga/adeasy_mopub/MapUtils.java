package com.zenozaga.adeasy_mopub;
import java.util.HashMap;

public class MapUtils {

    private  HashMap<String, Object> object;

    MapUtils(){
        object = new HashMap<String, Object>();
    };


    public MapUtils put(String key, Object data){

        object.put(key,data);
        return this;

    }


    public HashMap map (){
        return object;
    }


    public static  MapUtils getInstance(){
        return new MapUtils();
    }

    public static  boolean isMap(Object item){
        return item instanceof HashMap;
    }

    public static Object getIn(Object item, String key){

        if(item instanceof HashMap){
            return ((HashMap<?, ?>) item).get(key);
        }else{
            return null;
        }

    }

}
