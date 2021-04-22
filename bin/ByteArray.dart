 // ignore_for_file: omit_local_variable_types

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;


class ByteArray implements TypedData
{
    var _data = ByteData(16);
    var _count = 0;
    var readOffset = 0;
    var writeOffset = 0;

    @override
    ByteBuffer get buffer => _data.buffer;

    @override
    int get elementSizeInBytes => 1;

    @override
    int get lengthInBytes => _count;

    @override
    int get offsetInBytes => 0;

    int get count => _count;

    set count(int newCount)
    {
        if (_count < newCount)
        {
            fillBytes(0, _count, newCount-_count);
        }
        else if (_count > newCount)
        {
            fillBytes(0, newCount, _count - newCount);
        }

        _count = newCount;
    }

    static ByteData copyByteData(ByteData src,int srcIndex, ByteData dst, int dstIndex, int count)
    {
        while (count>0)
        {
            if (count>=4)
            {
              dst.setInt32(dstIndex, src.getInt32(srcIndex));
              count -= 4;
              srcIndex += 4;
              dstIndex += 4;
            }
            else
            {
              dst.setUint8(dstIndex++, src.getUint8(srcIndex++));
              count--;
            }
        }

        return dst;
    }

    void _expandCapacity(int capacity)
    {
        if (capacity>_data.lengthInBytes)
        {
            capacity = capacity>2*_data.lengthInBytes ? capacity : 2*_data.lengthInBytes;
            _data = copyByteData(_data,0,ByteData(capacity),0,_data.lengthInBytes);
        }
    }

    int get capacity => _data.lengthInBytes;

    set capacity(int newCapacity)
    {
        if (newCapacity != _data.lengthInBytes)
        {
            var size = math.min(newCapacity,_data.lengthInBytes);
            _data = copyByteData(_data,0,ByteData(newCapacity),0,size);
        }
    }

    // ---------------------------------------------------------------------------------------------------

    ByteArray writeUint8(int value)
    {
        _expandCapacity(writeOffset+1);
        _data.setUint8(writeOffset++, value);
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setUint8(int value,int offset)
    {
        _expandCapacity(offset+1);
        _data.setUint8(offset, value);
        return this;
    }

    int readUint8()
    {
        return _data.getUint8(readOffset++);
    }

    int getUint8(int offset)
    {
        return _data.getUint8(offset);
    }

    // ---------------------------------------------------------------------------------------------------

    ByteArray writeInt8(int value)
    {
        _expandCapacity(writeOffset+1);
        _data.setInt8(writeOffset++, value);
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setInt8(int value,int offset)
    {
        _expandCapacity(offset+1);
        _data.setInt8(offset, value);
        return this;
    }

    int readInt8()
    {
        return _data.getInt8(readOffset++);
    }

    int getInt8(int offset)
    {
        return _data.getInt8(offset);
    }

    // ---------------------------------------------------------------------------------------------------

    ByteArray writeUint16(int value,[Endian endian = Endian.big])
    {
        _expandCapacity(writeOffset+2);
        _data.setUint16(writeOffset, value,endian);
        writeOffset += 2;
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setUint16(int value,int offset,[Endian endian = Endian.big])
    {
        _expandCapacity(offset+2);
        _data.setUint16(offset, value, endian);
        return this;
    }

    int readUint16([Endian endian = Endian.big])
    {
        var result = _data.getUint16(readOffset,endian);
        readOffset += 2;
        return result;
    }

    int getUint16(int offset,[Endian endian = Endian.big])
    {
        return _data.getUint16(offset,endian);
    }

    // ---------------------------------------------------------------------------------------------------

    ByteArray writeInt16(int value,[Endian endian = Endian.big])
    {
        _expandCapacity(writeOffset+2);
        _data.setInt16(writeOffset, value,endian);
        writeOffset += 2;
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setInt16(int value,int offset,[Endian endian = Endian.big])
    {
        _expandCapacity(offset+2);
        _data.setInt16(offset, value, endian);
        return this;
    }

    int readInt16([Endian endian = Endian.big])
    {
        var result = _data.getInt16(readOffset,endian);
        readOffset += 2;
        return result;
    }

    int getInt16(int offset,[Endian endian = Endian.big])
    {
        return _data.getInt16(offset,endian);
    }

    // ---------------------------------------------------------------------------------------------------

    ByteArray writeUint32(int value,[Endian endian = Endian.big])
    {
        _expandCapacity(writeOffset+4);
        _data.setUint32(writeOffset, value,endian);
        writeOffset += 4;
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setUint32(int value,int offset,[Endian endian = Endian.big])
    {
        _expandCapacity(offset+4);
        _data.setUint32(offset, value, endian);
        return this;
    }

    int readUint32([Endian endian = Endian.big])
    {
        var result = _data.getUint32(readOffset,endian);
        readOffset += 4;
        return result;
    }

    int getUint32(int offset,[Endian endian = Endian.big])
    {
        return _data.getUint32(offset,endian);
    }

    // ---------------------------------------------------------------------------------------------------

    ByteArray writeInt32(int value,[Endian endian = Endian.big])
    {
        _expandCapacity(writeOffset+4);
        _data.setInt32(writeOffset, value,endian);
        writeOffset += 4;
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setInt32(int value,int offset,[Endian endian = Endian.big])
    {
        _expandCapacity(offset+4);
        _data.setInt32(offset, value, endian);
        return this;
    }

    int readInt32([Endian endian = Endian.big])
    {
        var result = _data.getInt32(readOffset,endian);
        readOffset += 4;
        return result;
    }

    int getInt32(int offset,[Endian endian = Endian.big])
    {
        return _data.getInt32(offset,endian);
    }

    // ---------------------------------------------------------------------------------------------------

    void setBytes(List<int> values,int offset)
    {
        _expandCapacity(offset+values.length);
        for(var value in values)
        {
          _data.setUint8(offset++, value);
        }
    }

    // ---------------------------------------------------------------------------------------------------

    void fillBytes(int value,int offset, int count,)
    {
        _expandCapacity(offset+count);

        while (count>0)
        {
          _data.setUint8(offset++, value);
          count--;
        }
    }

    // ---------------------------------------------------------------------------------------------------

    int setString(String value,int offset, {Encoding? encoding,bool zeroEnding=false,int size=-1,})
    {

        List<int> bytes = (encoding ?? utf8).encode(value);
        if (zeroEnding)
        {
          bytes.add(0);
        }

        if (size>0)
        {
            if (size>bytes.length)
            {
              while (size>bytes.length)
              {
                  bytes.add(0);
              }
            }
            else if (size<bytes.length)
            {
              while (size<bytes.length)
              {
                 bytes.removeLast();
              }
              if (zeroEnding)
              {
                  bytes.removeLast();
                  bytes.add(0);
              }
            }
        }

        setBytes(bytes,offset);

        return bytes.length;
    }

    int writeString(String value,int offset, {Encoding? encoding,bool zeroEnding=false,int size=-1,})
    {
        var strLen = setString(value, writeOffset,encoding: encoding, zeroEnding: zeroEnding, size: size);

        writeOffset += strLen;
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }

        return strLen;
    }

    String getString(int offset,int size,{Encoding? encoding,bool zeroEnding=false,})
    {
        var result = '';


        if (zeroEnding)
        {
            int endPoint = offset+size;

            for(var i=offset;i<endPoint; i++)
            {
                if (_data.getUint8(i) == 0)
                {
                    size = i-offset;
                    break;
                }
            }
        }

        var data = _data.buffer.asUint8List(offset,math.min(size,_count-offset));
        result = (encoding ?? utf8).decode(data);

        return result;

    }

    // ---------------------------------------------------------------------------------------------------

    void clear()
    {
        _count = 0;
        readOffset = 0;
        writeOffset = 0;

    }

    ByteBuffer asByteBuffer()
    {
        return _data.buffer;
    }

    ByteData asByteData([int offsetInBytes = 0, int? length])
    {
        return _data.buffer.asByteData(offsetInBytes,length ?? _count);
    }

    // ---------------------------------------------------------------------------------------------------

    void _hexChar(StringBuffer builder,int value)
    {
        value &= 0xf;
        builder.writeCharCode( (value<=9) ? (value+0x30) : (value-10+0x41));
    }

    String toHexString(int offset,int count,[String space=' '])
    {
        var builder = StringBuffer();

        while (count>0)
        {
            count--;
            var value = _data.getUint8(offset++);
            _hexChar(builder, value>>4);
            _hexChar(builder, value);
            if (count>0)
            {
                builder.write(space);
            }
        }

        return builder.toString();
    }

    @override
    String toString()
    {
      return toHexString(0, _count);
    }
}
