#ifndef UNREAL_PROTOBUF_ALLOCATOR_H_
#define UNREAL_PROTOBUF_ALLOCATOR_H_

#include <deque>
#include <queue>
#include <map>
#include <memory>
#include <set>
#include <string>
#include <sstream>
#include <unordered_map>
#include <utility>
#include <vector>

namespace ue4 {

    template <typename T>
    class unreal_allocator : public std::allocator<T>
    {
    public:
        typedef size_t size_type;
        typedef T* pointer;
        typedef const T* const_pointer;

        template<typename _Tp1>
        struct rebind
        {
            typedef unreal_allocator<_Tp1> other;
        };

#ifdef UNREAL_PROTOBUF_ALLOCATOR

        pointer allocate(size_type n, const void *hint = 0)
        {
            return reinterpret_cast<pointer>(FMemory::Malloc(n * sizeof(T)));
        }

        void deallocate(pointer p, size_type /* size_type */)
        {
            return FMemory::Free(p);
        }
#endif

        unreal_allocator() throw() : std::allocator<T>() { }
        unreal_allocator(const unreal_allocator &a) throw() : std::allocator<T>(a) { }

        template <class U>
        unreal_allocator(const unreal_allocator<U> &a) throw() : std::allocator<T>(a) {}
        ~unreal_allocator() throw() {}
    };

    typedef std::basic_stringstream<char, std::char_traits<char>, unreal_allocator<char>> stringstream;
    typedef std::basic_string<char, std::char_traits<char>, unreal_allocator<char>> string;
    typedef std::basic_ostringstream<char, std::char_traits<char>, unreal_allocator<char>> ostringstream;


    template<typename _Ty>
    using vector = std::vector<_Ty, unreal_allocator<_Ty>>;

    template<typename _Ty>
    using deque = std::deque<_Ty, unreal_allocator<_Ty>>;

    template<typename _Ty>
    using queue = std::queue<_Ty, deque<_Ty>>;

    template<typename _Ty>
    using set = std::set<_Ty, std::less<_Ty>, unreal_allocator<_Ty>>;

    template<typename _Kty, typename _Ty>
    using map = std::map<_Kty, _Ty, std::less<_Kty>, unreal_allocator<std::pair<const _Kty, _Ty>>>;

    template<typename _Kty, typename _Ty>
    using unordered_map = std::unordered_map<_Kty, _Ty, std::hash<_Kty>, std::equal_to<_Kty>, unreal_allocator<std::pair<const _Kty, _Ty>>>;


}

#endif