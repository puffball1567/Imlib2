import std/unittest
import imlib2

var
  destructorCalled = false
  imageDataReleased = 0

proc progressCallback(image: Imlib_Image; percent: cchar; updateX, updateY,
    updateW, updateH: cint): cint {.cdecl.} =
  discard image
  discard percent
  discard updateX
  discard updateY
  discard updateW
  discard updateH
  1

proc dataDestructor(image: Imlib_Image; data: pointer) {.cdecl.} =
  discard image
  discard data
  destructorCalled = true

proc imageDataMemory(data: pointer; size: csize_t): pointer {.cdecl.} =
  if data == nil:
    result = alloc(size)
  else:
    dealloc(data)
    inc imageDataReleased

suite "Imlib2 1.12.6 headless compatibility":
  test "creates, selects, queries, and frees an image":
    check imlib_version() == IMLIB2_VERSION
    check sizeof(Imlib_Frame_Info) == 11 * sizeof(cint)

    let image = imlib_create_image(2, 3)
    require image != nil
    imlib_context_set_image(image)
    check imlib_image_get_width() == 2
    check imlib_image_get_height() == 3
    imlib_free_image()

  test "C callbacks retain their calling conventions":
    imlib_context_set_progress_function(progressCallback)
    check imlib_context_get_progress_function() != nil
    imlib_context_set_progress_function(nil)

    imlib_context_set_image_data_memory_function(imageDataMemory)
    check imlib_context_get_image_data_memory_function() != nil
    imlib_context_set_image_data_memory_function(nil)

    let pixels = cast[ptr DATA32](alloc(6 * sizeof(DATA32)))
    let image = imlib_create_image_using_data_and_memory_function(
      2, 3, pixels, imageDataMemory)
    if image == nil:
      dealloc(pixels)
    require image != nil
    imlib_context_set_image(image)
    imlib_image_attach_data_value("callback-test", nil, 0, dataDestructor)
    imlib_image_remove_and_free_attached_data_value("callback-test")
    check destructorCalled
    imlib_free_image()
    check imageDataReleased == 1

  test "new error API returns library-owned text":
    check imlib_strerror(IMLIB_ERR_NO_LOADER) != nil
