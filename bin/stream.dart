 // ignore_for_file: omit_local_variable_types
import 'dart:convert';
import 'dart:mirrors';

import 'ByteArray.dart';



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


void main(List<String> arguments) async
{

  //////////////////////////////////////////////////////////////////////////////////////////
  var ba = ByteArray();

  ba.writeString("Žluva říhá", 0);
  ba.count = 40;
  /*for (int i=0; i<100; i++)
    ba.writeInt32(i);

  ba.writeInt8(127);*/
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