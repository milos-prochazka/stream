import 'dart:typed_data';


import 'dart:convert';

import 'dart:mirrors';



dynamic setDynamic(dynamic parent,dynamic value,List<dynamic> args,{ int argIndex = 0})
{
    dynamic result;

    if (argIndex >= args.length)
    {
        if (value is bool || value is double || value is String || value is int || value == null)
        {
            result = value;
        } 
        else if (value is List || value is Set)
        {
            var array = <dynamic>[];
            for (var item in value)
            {
                array.add(setDynamic(null, item, args,argIndex:argIndex));
            }

            result = array;
        }
        else if (value is Map)
        {
            var obj = <String,dynamic>{};
            for (var item in value.entries)
            {
                obj[item.key.toString()] = setDynamic(null, item.value, args,argIndex:argIndex);
            }
            result = obj;
        }
        else 
        {
            var obj = <String,dynamic>{};
            var clsMirror = reflectClass(value.runtimeType);
            var mirror = reflect(value);
            
            for(var member in clsMirror.declarations.values)
            {
                
                if (!member.isPrivate)
                {                  
                    if (member is VariableMirror || (member as MethodMirror).isGetter)
                    {
                        obj[MirrorSystem.getName(member.simpleName)] = 
                            setDynamic(null, mirror.getField( member.simpleName).reflectee, args,argIndex:argIndex);
                    }
                }
            }

            result = obj;
            //throw UnimplementedError('Object settings are not implemented');
        }
    }
    else
    {
        var arg = args[argIndex];

        if (arg is int)
        {
            var index = arg as int;

            if (!(parent is List<dynamic> ))
            {
                parent = <dynamic>[];
            }

            if (index<0 || index>= parent.length)
            {
                parent.add(null);
                index = parent.length-1;
                parent[index] = setDynamic(null, value, args, argIndex:argIndex+1);
            }
            else
            {
                parent[index] = setDynamic(parent[index], value, args, argIndex:argIndex+1);
            }

            result = parent;
        }
        else if (arg is String)
        {
            var name = arg as String;

            if (!(parent is Map<String,dynamic>))
            {
                parent = <String,dynamic>{};
            }

            if (parent.containsKey(name))
            {
                parent[name] = setDynamic(parent[name], value, args, argIndex:argIndex+1);
            }
            else
            {
                parent[name] = setDynamic(null, value, args, argIndex:argIndex+1);
            }
            result = parent;
        }
        else
        {
            throw ArgumentError("'args' must be type int or string");
        }
    }

    return result;
}

dynamic getDynamic(dynamic parent,dynamic defaultValue,List<dynamic> args,{ int argIndex = 0})
{
    dynamic result;
    if (argIndex >= args.length)
    {
        result = parent;
    }
    else
    {
        var arg = args[argIndex];

        if (arg is int)
        {
            var index = arg as int;

            if (!(parent is List<dynamic> ))
            {
                result = defaultValue;
            }
            else
            {
              if (index<0)
              {
                  index = parent.length - 1;
              }
              if (index<0 || index>= parent.length)
              {
                  result = defaultValue;
              }
              else
              {
                  result = getDynamic(parent[index], defaultValue, args, argIndex:argIndex+1);
              }
            }

        }
        else if (arg is String)
        {
            var name = arg as String;

            if (!(parent is Map<String,dynamic>))
            {
                result = defaultValue;
            }
            else if (parent.containsKey(name))
            {
                result = getDynamic(parent[name], defaultValue, args, argIndex:argIndex+1);
            }
            else
            {
                result = defaultValue;
            }
        }
        else
        {
            throw ArgumentError("'args' must be type int or string");
        }
    }

    return result;

}


Stream<String> lines(Stream<String> source) async* 
{
  // Stores any partial line from the previous chunk.
  var partial = '';
  // Wait until a new chunk is available, then process it.
  await for (var chunk in source) 
  {
    var lines = chunk.split('\n');
    lines[0] = partial + lines[0]; // Prepend partial line.
    partial = lines.removeLast(); // Remove new partial line.
    for (var line in lines) 
    {
      yield line; // Add lines to output stream.
    }
  }
  // Add final partial line to output stream, if any.
  if (partial.isNotEmpty) yield partial;
}

Stream<String> genLines(int time) async*
{
    for (int i=1; i<20; i++)
    {
        await Future.delayed(Duration(milliseconds: time));
        yield ('line:$i');
    }
}


const info = Object();

class clsTest
{
    @info
    var jaja = "jaja";
    var paja = 444;
    var tm43 = false;
    var _private = 34.55;

    clsTest.fromVoid()
    {
      tm43 = true;
    }
}

class ByteArray implements TypedData
{
    var _data = ByteData(32);
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

    static ByteData copy(ByteData src,int srcIndex, ByteData dst, int dstIndex, int count)
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

    void _setCapacity(int capacity) 
    {
        if (capacity>_data.lengthInBytes)
        {
            capacity = capacity>2*_data.lengthInBytes ? capacity : 2*_data.lengthInBytes;
            _data = copy(_data,0,ByteData(capacity),0,_data.lengthInBytes);
        }
    }

    // ---------------------------------------------------------------------------------------------------
  
    ByteArray writeUint8(int value)
    {
        _setCapacity(writeOffset+1);
        _data.setUint8(writeOffset++, value);
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setUint8(int value,int offset)
    {
        _setCapacity(offset+1);
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
        _setCapacity(writeOffset+1);
        _data.setInt8(writeOffset++, value);
        if (writeOffset>_count)
        {
            _count = writeOffset;
        }
        return this;
    }

    ByteArray setInt8(int value,int offset)
    {
        _setCapacity(offset+1);
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
        _setCapacity(writeOffset+2);
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
        _setCapacity(offset+2);
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
        _setCapacity(writeOffset+2);
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
        _setCapacity(offset+2);
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
        _setCapacity(writeOffset+4);
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
        _setCapacity(offset+4);
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
        _setCapacity(writeOffset+4);
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
        _setCapacity(offset+4);
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
    
    void _hexChar(StringBuffer builder,int value)
    {
        value &= 0xf;
        builder.writeCharCode( (value<=9) ? (value+0x30) : (value-10+0x41));
    }
    
    String toStringEx(int offset,int count,[String space=' '])
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
      return toStringEx(0, _count);
    }
}


void main(List<String> arguments) async
{

  //////////////////////////////////////////////////////////////////////////////////////////
  var ba = ByteArray();
  for (int i=0; i<100; i++)
    ba.writeInt32(i);

  ba.writeInt8(127);
  var s = ba.toString();
  //////////////////////////////////////////////////////////////////////////////////////////

  var inst = clsTest.fromVoid();

  var dd = setDynamic(null,inst,['jaja','paja',20]);
  
  var qq = getDynamic(dd, null , ['jaja','paja',-1]);


  
  var mirror = reflectClass(inst.runtimeType);
  var instanceMirror = reflect(inst);
  instanceMirror.setField(Symbol('paja'), 2345);
  
  for(var declare in mirror.declarations.entries)
  {
    var decl = declare.value;
    if (!decl.isPrivate && decl is MethodMirror)
    {
      print ('${declare.key.toString()} ${decl.simpleName}');
      var type = reflectType(decl.runtimeType);
      for (var meta in decl.metadata)
      {
          if (meta.reflectee == info)
          {
              print ("  !!!!");
          }
      }
    }
  };

  String json = jsonEncode(dd);

  //////////////////////////////////////////////////////////////////////////////////////////

  var str = genLines(300);

  str.any((line) 
  {
      print (line);
      return false;
  });

  var str1 = genLines(220);
  
  str1.any((line) 
  {
      print ('s1:$line');
      return false;
  });

  /*await for(var line in str)
  {
      print (line);
  }*/
}
