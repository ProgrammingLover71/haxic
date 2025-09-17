# Haxic Standard Library for programs compiled to Python.

from time import perf_counter_ns
from types import NoneType
from typing import Callable
from os import system
from sys import platform
import math as _sys_math

hxc_number = float
hxc_string = str
hxc_array = list
hxc_map = dict
type hxc_function = Callable
hxc_null = NoneType
type hxc_any = hxc_number | hxc_string | hxc_array | hxc_map | hxc_null | hxc_function


def clock() -> hxc_number:
    return perf_counter_ns() / 1e9

def length(item: hxc_any) -> hxc_number:
    if isinstance(item, hxc_string | hxc_array):
        return len(item)
    if isinstance(item, hxc_map):
        return len(item.keys())
    if isinstance(item, hxc_function):
        return len(item.__code__.co_argcount)
    raise Exception("length() argument must be a string, array, map or function")

def typeof(item: hxc_any) -> hxc_string:
    if isinstance(item, hxc_string): return "string"
    if isinstance(item, hxc_array): return "array"
    if isinstance(item, hxc_number): return "number"
    if isinstance(item, hxc_map): return "map"
    if isinstance(item, hxc_function): return "function"
    if item == None: return "null"

def clear() -> hxc_null:
    if platform in ["win32", "msys", "cygwin"]:
        system("cls")
    else:
        system("clear")

def map(arr: hxc_array, func: hxc_function) -> hxc_array:
    result = []
    for item in arr:
        result.append(func(item))
    return result

def toString(item: hxc_any) -> hxc_string:
    return str(item)


def __math_sqrt(num: hxc_number) -> hxc_number:
    return _sys_math.sqrt(num)

def __math_sin(num: hxc_number) -> hxc_number:
    return _sys_math.sin(num)

def __math_cos(num: hxc_number) -> hxc_number:
    return _sys_math.cos(num)

def __math_tan(num: hxc_number) -> hxc_number:
    return _sys_math.tan(num)

def __math_pow(x: hxc_number, y: hxc_number) -> hxc_number:
    return _sys_math.pow(x, y)

math = {
    "sqrt": __math_sqrt,
    "sin": __math_sin,
    "cos": __math_cos,
    "tan": __math_tan,
    "pow": __math_pow,
}