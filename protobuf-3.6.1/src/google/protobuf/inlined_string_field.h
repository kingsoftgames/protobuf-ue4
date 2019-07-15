// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.  All rights reserved.
// https://developers.google.com/protocol-buffers/
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef GOOGLE_PROTOBUF_INLINED_STRING_FIELD_H__
#define GOOGLE_PROTOBUF_INLINED_STRING_FIELD_H__

#include <string>

#include <google/protobuf/stubs/port.h>
#include <google/protobuf/stubs/stringpiece.h>

namespace google {
namespace protobuf {

class Arena;

namespace internal {

// InlinedStringField wraps a ::ue4::string instance and exposes an API similar to
// ArenaStringPtr's wrapping of a ::ue4::string* instance.  As ::ue4::string is never
// allocated on the Arena, we expose only the *NoArena methods of
// ArenaStringPtr.
//
// default_value parameters are taken for consistency with ArenaStringPtr, but
// are not used for most methods.  With inlining, these should be removed from
// the generated binary.
class LIBPROTOBUF_EXPORT InlinedStringField {
 public:
  InlinedStringField()
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;
  explicit InlinedStringField(const ::ue4::string& default_value);

  void AssignWithDefault(const ::ue4::string* default_value,
                         const InlinedStringField& from)
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

  void ClearToEmpty(const ::ue4::string* default_value, Arena* arena)
      GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    ClearToEmptyNoArena(default_value);
  }
  void ClearNonDefaultToEmpty() GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    ClearNonDefaultToEmptyNoArena();
  }
  void ClearToEmptyNoArena(const ::ue4::string* default_value)
      GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    ClearNonDefaultToEmptyNoArena();
  }
  void ClearNonDefaultToEmptyNoArena()
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

  void ClearToDefault(const ::ue4::string* default_value, Arena* arena)
      GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    ClearToDefaultNoArena(default_value);
  }
  void ClearToDefaultNoArena(const ::ue4::string* default_value)
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

  void Destroy(const ::ue4::string* default_value, Arena* arena)
      GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    DestroyNoArena(default_value);
  }
  void DestroyNoArena(const ::ue4::string* default_value)
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

  const ::ue4::string& Get() const GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    return GetNoArena();
  }
  const ::ue4::string& GetNoArena() const GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

  ::ue4::string* Mutable(const ::ue4::string* default_value, Arena* arena)
      GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    return MutableNoArena(default_value);
  }
  ::ue4::string* MutableNoArena(const ::ue4::string* default_value)
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

  ::ue4::string* Release(const ::ue4::string* default_value, Arena* arena) {
    return ReleaseNoArena(default_value);
  }
  ::ue4::string* ReleaseNonDefault(const ::ue4::string* default_value, Arena* arena) {
    return ReleaseNonDefaultNoArena(default_value);
  }
  ::ue4::string* ReleaseNoArena(const ::ue4::string* default_value) {
    return ReleaseNonDefaultNoArena(default_value);
  }
  ::ue4::string* ReleaseNonDefaultNoArena(const ::ue4::string* default_value);

  void Set(const ::ue4::string* default_value,
           StringPiece value,
           Arena* arena) GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    SetNoArena(default_value, value);
  }
  void SetLite(const ::ue4::string* default_value,
               StringPiece value,
               Arena* arena) GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    SetNoArena(default_value, value);
  }
  void SetNoArena(const ::ue4::string* default_value,
                  StringPiece value) GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

  void Set(const ::ue4::string* default_value,
           const ::ue4::string& value,
           Arena* arena) GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    SetNoArena(default_value, value);
  }
  void SetLite(const ::ue4::string* default_value,
               const ::ue4::string& value,
               Arena* arena) GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE {
    SetNoArena(default_value, value);
  }
  void SetNoArena(const ::ue4::string* default_value,
                  const ::ue4::string& value)
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;

#if LANG_CXX11
  void SetNoArena(const ::ue4::string* default_value,
                  ::ue4::string&& value)
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;
#endif
  void SetAllocated(const ::ue4::string* default_value,
                    ::ue4::string* value,
                    Arena* arena) {
    SetAllocatedNoArena(default_value, value);
  }
  void SetAllocatedNoArena(const ::ue4::string* default_value,
                           ::ue4::string* value);
  void Swap(InlinedStringField* from)
    GOOGLE_PROTOBUF_ATTRIBUTE_ALWAYS_INLINE;
  ::ue4::string* UnsafeMutablePointer();
  void UnsafeSetDefault(const ::ue4::string* default_value);
  ::ue4::string* UnsafeArenaRelease(const ::ue4::string* default_value, Arena* arena);
  void UnsafeArenaSetAllocated(
      const ::ue4::string* default_value, ::ue4::string* value, Arena* arena);

  bool IsDefault(const ::ue4::string* default_value) {
    return false;
  }
 private:
  ::ue4::string value_;
};

inline InlinedStringField::InlinedStringField() {}

inline InlinedStringField::InlinedStringField(const ::ue4::string& default_value) :
  value_(default_value) {}

inline void InlinedStringField::AssignWithDefault(
    const ::ue4::string* default_value, const InlinedStringField& from) {
  value_ = from.value_;
}

inline const ::ue4::string& InlinedStringField::GetNoArena() const {
  return value_;
}

inline ::ue4::string* InlinedStringField::MutableNoArena(const ::ue4::string*) {
  return &value_;
}

inline void InlinedStringField::SetAllocatedNoArena(
    const ::ue4::string* default_value, ::ue4::string* value) {
  if (value == NULL) {
    value_.assign(*default_value);
  } else {
#if LANG_CXX11
    value_.assign(std::move(*value));
#else
    value_.swap(*value);
#endif
    delete value;
  }
}

inline void InlinedStringField::DestroyNoArena(const ::ue4::string*) {
  // This is invoked from the generated message's ArenaDtor, which is used to
  // clean up objects not allocated on the Arena.
  this->~InlinedStringField();
}

inline void InlinedStringField::ClearNonDefaultToEmptyNoArena() {
  value_.clear();
}

inline void InlinedStringField::ClearToDefaultNoArena(
    const ::ue4::string* default_value) {
  value_.assign(*default_value);
}

inline ::ue4::string* InlinedStringField::ReleaseNonDefaultNoArena(
    const ::ue4::string* default_value) {
  ::ue4::string* released = new ::ue4::string(*default_value);
  value_.swap(*released);
  return released;
}

inline void InlinedStringField::SetNoArena(
    const ::ue4::string* default_value, StringPiece value) {
  value_.assign(value.data(), value.length());
}

inline void InlinedStringField::SetNoArena(
    const ::ue4::string* default_value, const ::ue4::string& value) {
  value_.assign(value);
}

#if LANG_CXX11
inline void InlinedStringField::SetNoArena(
    const ::ue4::string* default_value, ::ue4::string&& value) {
  value_.assign(std::move(value));
}
#endif

inline void InlinedStringField::Swap(InlinedStringField* from) {
  value_.swap(from->value_);
}

inline ::ue4::string* InlinedStringField::UnsafeMutablePointer() {
  return &value_;
}

inline void InlinedStringField::UnsafeSetDefault(
    const ::ue4::string* default_value) {
  value_.assign(*default_value);
}

inline ::ue4::string* InlinedStringField::UnsafeArenaRelease(
    const ::ue4::string* default_value, Arena* arena) {
  return ReleaseNoArena(default_value);
}

inline void InlinedStringField::UnsafeArenaSetAllocated(
    const ::ue4::string* default_value, ::ue4::string* value, Arena* arena) {
  if (value == NULL) {
    value_.assign(*default_value);
  } else {
    value_.assign(*value);
  }
}

}  // namespace internal
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_INLINED_STRING_FIELD_H__
