

import 'DynamicByteBuffer.dart';

class BxDocument
{
    DynamicByteBuffer _binarydata = DynamicByteBuffer();
    List<String> wordList = <String>[];
    Map<String,int> wordDictionary = <String,int>{};

    int writeString(String value)
    {
        var result = wordDictionary[value] ?? -1;
        if (result >= 0)
        {
            if (result<(0xE000-0x8000))
            {
                _binarydata.writeUint16(result+0x8000);
            }
            else
            {
                _binarydata.writeUint8(0xfe);
                _binarydata.writeInt32(result);
            }
        }
        else
        {
            var data = DynamicByteBuffer.utf8.encode(value);
            if (value.length<0x80)
            {
                _binarydata.writeUint8(data.length);
            }
            else
            {
                _binarydata.writeUint8(0xfd);
                _binarydata.writeUint16(data.length);
            }

            _binarydata.writeBytes(data);
            result = wordList.length;
            wordList.add(value);
            wordDictionary[value] = result;
        }
        return result;
    }

}