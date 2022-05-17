package unic.cicoco.cordova.obsclient;

import android.text.TextUtils;

import com.obs.services.ObsClient;
import com.obs.services.exception.ObsException;
import com.obs.services.model.PutObjectResult;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.camera.FileHelper;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.UUID;

/**
 * <p>
 * </p>
 *
 * @author tafiagu@gmail.com
 * @since 2021/10/28 9:04 下午
 */
public class ObsClientPlugin extends CordovaPlugin {

    private static final String TAG = "ObsClientPlugin";

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("upload")) {
            LOG.d(TAG, "do upload, args:" + (null == args ? "nil" : args.toString()));
            upload(args, callbackContext);
            return true;
        }
        return false;

    }


    private void upload(JSONArray args, CallbackContext callbackContext) throws JSONException {
        String filePath = args.getString(0);
        HWCredential credential = new HWCredential();
        credential.ak = args.getString(1);
        credential.sk = args.getString(2);
        credential.endpoint = args.getString(3);
        credential.bucket = args.getString(4);
        credential.prefix = args.getString(5);
        credential.token = args.getString(6);
        final String fileName = args.getString(7);

        if(!filePath.startsWith("/")){
            filePath = FileHelper.getRealPath(filePath, cordova);
        }

        if (TextUtils.isEmpty(filePath)) {
            callbackContext.error("get file error");
            return;
        }

        final String _filePath = filePath;
        cordova.getThreadPool().submit(() -> {
            if (null == credential) {
                LOG.d(TAG, "credential is null");
                callbackContext.error("get credential null");
                return;
            }

            // 2. 上传文件
            ObsClient client = new ObsClient(credential.ak, credential.sk, credential.token, credential.endpoint);

            File file = new File(_filePath);
            try {
                String _fileName = (null == fileName || fileName.isEmpty())? file.getName() : fileName;
                PutObjectResult result = client.putObject(credential.bucket,
                        credential.prefix + _fileName, file);

                if (200 == result.getStatusCode()) {
                    LOG.d(TAG, "upload success:" + result.getObjectUrl());
                    callbackContext.success(result.getObjectUrl());
                } else {
                    LOG.d(TAG, "code:" + result.getStatusCode());
                    callbackContext.error("upload failed");
                }
            } catch (ObsException e) {
                LOG.e(TAG, e.getMessage(), e);
                callbackContext.error("upload error");
            } finally {
                try {
                    client.close();
                } catch (IOException e) {
                }
            }
        });
    }


    private static class HWCredential {

        String ak;
        String sk;
        String endpoint;
        String bucket;
        String prefix;
        String token;

        @Override
        public String toString() {
            return "HWCredential{" +
                    "ak='" + ak + '\'' +
                    ", sk='" + sk + '\'' +
                    ", endpoint='" + endpoint + '\'' +
                    ", bucket='" + bucket + '\'' +
                    ", prefix='" + prefix + '\'' +
                    ", token='" + token + '\'' +
                    '}';
        }
    }
}
