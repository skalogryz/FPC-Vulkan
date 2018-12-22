(*
** Delphi-Vulkan
**
** Copyright (c) 2016 Maksym Tymkovych
*)

Program Test;

{$ifdef fpc}{$mode delphi}{$endif}
{$ifdef mswindows}{$APPTYPE CONSOLE}{$endif}

uses
  vk_platform, vulkan;


function AppAlloc(
  pUserData: Pointer;
  size: size_t;
  alignment: size_t;
  allocationScope: TVkSystemAllocationScope
): Pointer; {$IFDEF CDECL}cdecl{$ELSE}stdcall{$ENDIF};
begin
  Result := GetMemory(size);
end;

function AppRealloc(
  pUserData: Pointer;
  pOriginal: Pointer;
  size: size_t;
  alignment: size_t;
  allocationScope: TVkSystemAllocationScope
): Pointer; {$IFDEF CDECL}cdecl{$ELSE}stdcall{$ENDIF};
begin
  Result := ReallocMemory(pOriginal,size);
end;

procedure AppFree(
  pUserData: Pointer;
  pMemory: Pointer
); {$IFDEF CDECL}cdecl{$ELSE}stdcall{$ENDIF};
begin
  FreeMemory(pMemory);
end;



const
  appInfo: TVkApplicationInfo = (
    sType:              VK_STRUCTURE_TYPE_APPLICATION_INFO;
    pNext:              nil;
    pApplicationName:   'Test';
    applicationVersion: 0;
    pEngineName:        'Test';
    engineVersion:      0;
    apiVersion:         0;
  );

  instInfo: TVkInstanceCreateInfo = (
    sType:                   VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    pNext:                   nil;
    flags:                   0;
    pApplicationInfo:        @appInfo;
    enabledLayerCount:       0;
    ppEnabledLayerNames:     nil;
    enabledExtensionCount:   0;
    ppEnabledExtensionNames: nil;
  );

var
  allocator: TVkAllocationCallbacks = (
    pUserData:             nil;
    pfnAllocation:         AppAlloc;
    pfnReallocation:       AppRealloc;
    pfnFree:               AppFree;
    pfnInternalAllocation: nil;
    pfnInternalFree:       nil;
  );

var
  instance: PVkInstance;
  err: TVkResult;
begin
  InitVulkan(VulkanLibName);

  if @vkCreateInstance = nil then
  begin
    Exit;
  end;

  err := vkCreateInstance(@instInfo,@allocator,@instance);
  case err of
    VK_ERROR_INCOMPATIBLE_DRIVER:   Writeln('Incompatible driver');
    VK_ERROR_EXTENSION_NOT_PRESENT: Writeln('Extension not present');
    VK_ERROR_LAYER_NOT_PRESENT:     Writeln('Layer not present');
    VK_ERROR_INITIALIZATION_FAILED: Writeln('Initialization failed');
    VK_ERROR_OUT_OF_DEVICE_MEMORY:  Writeln('Out of device memory');
    VK_ERROR_OUT_OF_HOST_MEMORY:    Writeln('Out of host memory');
    VK_SUCCESS:                     Writeln('Success');
  else
    Writeln('Unknown error: ', err);
  end;

  Writeln('Press any key...');
  Readln;
end.
